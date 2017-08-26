CREATE OR REPLACE PROCEDURE PRC_Wmmember_IMPORT (V_PID       IN     VARCHAR,
                                                 OUTSTATUS      OUT INTEGER)
AS
   --店铺号
   V_storeID         VARCHAR (10);
   V_membercardno    VARCHAR (20);                                        --会员
   V_name            VARCHAR (20);
   v_sfzh            VARCHAR (20);
   V_birthday        VARCHAR (20);
   V_sex             VARCHAR (10);
   V_provinceName    VARCHAR (60);
   V_cityName        VARCHAR (60);
   V_districtName    VARCHAR (60);
   V_phone           VARCHAR (20);
   V_address         VARCHAR (60);
   V_SUCCESS         CHAR (1);
   --V_FAIL       CHAR (1);
   V_OPR             CHAR (7);
   V_GetFAIL         NUMBER;
   ISCOMMIT          VARCHAR (2);
   CARDNO            VARCHAR2 (30);                                     --返回卡号
   CARDID            VARCHAR2 (30);

   V_title           VARCHAR2 (30);                                   --变更积分描述
   V_posints         NUMBER;                                           --变更积分值
   V_time            VARCHAR2 (30);
   V_pointspaytype   VARCHAR2 (5);                                    --积分变更类型
   V_operator        VARCHAR2 (30);                                      --操作人
   V_ADDORREDUCE     VARCHAR (2);                                     --积分操作类型
   V_CID             VARCHAR (30) := '';                                --会员ID
   V_allPoInts       number;                                            --会员积分
   
   --取微盟接口表会员
   CURSOR GETWMmember
   IS
      SELECT m.membercardno,
             m.name,
             '' sfzh,
             m.birthday,
             m.sex,
             m.provinceName,
             m.cityName,
             m.districtName,
             m.address,
             m.phone,
             m.allPoInts
        FROM WMMember m
       WHERE     pid = V_PID
             AND EXISTS
                    (SELECT 1
                       FROM WMPointslog p
                      WHERE m.pid = p.pid AND syncflag = 0);
   --取微盟接口表会员积分
   CURSOR GETWMPoints
   IS
      SELECT membercardno,
             name,
             title,
             storeid,
             points,
             time,
             pointspaytype,
             operator,
             ADDORREDUCE
        FROM WMPointslog
       WHERE pid = V_PID AND membercardno = V_membercardno AND syncflag = 0;
BEGIN
   V_SUCCESS := 1;
   --V_FAIL := 0;

   V_OPR := '0000000';


   SELECT REPLACE (LPAD (storeid, 4), ' ', '0')
     INTO V_storeID
     FROM wmgzh
    WHERE pid = V_PID;


   PRC_LOG (1,
            V_SUCCESS,
            V_OPR,
            '1',
            ' WMmember IMPORT start !!');


   --微盟会员表
   OPEN GETWMmember;

   LOOP
      FETCH GETWMmember
         INTO V_membercardno,
              V_name,
              V_sfzh,
              V_birthday,
              V_sex,
              V_provinceName,
              V_cityName,
              V_districtName,
              V_address,
              V_phone,
              V_allPoInts;

      EXIT WHEN GETWMmember%NOTFOUND;

      BEGIN
         SELECT COUNT (*)
           INTO V_GetFAIL
           FROM CUSTMEMBER
          WHERE cmmobile1 = V_phone;

         IF V_GetFAIL = 0
         THEN
            BEGIN
               ISCOMMIT := 'Y';
               CARDNO := NULL;
               CARDID := NULL;
               --增加会员到会员卡库
               DBUSRVIP.HY_WMMEMBERADD (v_PID,
                                        V_name,
                                        v_sfzh,
                                        V_BIRTHDAY,
                                        V_SEX,
                                        V_provinceName,
                                        V_cityName,
                                        V_districtName,
                                        V_address,
                                        V_phone,
                                        V_allPoInts,
                                        ISCOMMIT,
                                        CARDNO,
                                        CARDID);

               DBMS_OUTPUT.put_line (CARDNO);
            END;
         ELSE
            DBUSRVIP.HY_WMMemberUPdat (v_PID, V_phone);
         END IF;

         -- wmofflinevsonline   '微盟线下线上会员号对应表表';
         --根据手机号，匹配线上、现下会员到对应表　
         SELECT COUNT (*)
           INTO V_GetFAIL
           FROM wmofflinevsonline
          WHERE pid = V_PID AND wmmembercardno = V_membercardno;

         IF V_GetFAIL = 0
         THEN
            BEGIN
               INSERT INTO wmofflinevsonline
                      (pid, 
                       membercardno, 
                       wmmembercardno, 
                       dt)
                  SELECT V_PID, cmcustid, V_membercardno,sysdate
                    FROM CUSTMEMBER
                   WHERE cmmobile1 = V_phone;
            END;
         END IF;

         PRC_LOG (2,
                  V_SUCCESS,
                  V_OPR,
                  '1',
                  V_phone || ':WMmember is  SUCCESS!!');

         --'微盟会员积分流水';
         OPEN GETWMPoints;

         LOOP
            FETCH GETWMPoints
               INTO V_membercardno,
                    V_name,
                    V_title,
                    V_storeID,
                    V_POSINTS,
                    V_time,
                    V_pointspaytype,
                    V_operator,
                    V_ADDORREDUCE;


            EXIT WHEN GETWMPoints%NOTFOUND;

            BEGIN
               SELECT COUNT (*), MIN (cmmemid)
                 INTO V_GetFAIL, V_CID
                 FROM CUSTMEMBER
                WHERE cmmobile1 = V_phone;

               IF V_GetFAIL > 0
               THEN
                  BEGIN
                     --线上积分记录同步到现下
                     DBUSRVIP.HY_WMJFZJ (V_PID,
                                         V_CID,
                                         V_TITLE,
                                         V_STOREID,
                                         V_POSINTS,
                                         V_TIME,
                                         V_POINTSPAYTYPE,
                                         V_OPERATOR,
                                         V_ADDORREDUCE);
                  END;
               END IF;
            END;
         END LOOP;

         CLOSE GETWMPoints;
         
         --回写积分同步标志      
         UPDATE WMPointslog
            SET syncflag = 1
          WHERE     pid = V_PID
                AND membercardno = V_membercardno
                AND syncflag = 0;

         COMMIT;
      END;

      PRC_LOG (3,
               V_SUCCESS,
               V_OPR,
               '1',
               ' WMPointslog update  SUCCESS!!');
   END LOOP;

   CLOSE GETWMmember;

   PRC_LOG (4,
            V_SUCCESS,
            V_OPR,
            '1',
            ' WMmember update  SUCCESS!!');

   OUTSTATUS := 0;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      OUTSTATUS := SQLCODE;
      RETURN;
END PRC_Wmmember_IMPORT;




CREATE OR REPLACE PROCEDURE PRC_ToWmmember_middleTab (
   V_PID       IN     VARCHAR,
   OUTSTATUS      OUT INTEGER)
AS
   --店铺号
   --V_storeID         VARCHAR (10);                               --会员
   V_SUCCESS         CHAR (1);
   --V_FAIL       CHAR (1);
   V_OPR             CHAR (7);
   --V_GetFAIL         NUMBER;
  -- ISCOMMIT          VARCHAR (2); 
BEGIN
   V_SUCCESS := 1;
   --V_FAIL := 0;

   V_OPR := '0000000';

   PRC_LOG (1,
            V_SUCCESS,
            V_OPR,
            '2',
            '1 WMmember  TO offline start !!');

    --写入实体店会员表
   INSERT INTO WMOffLineMember (SYNCID,
                                SYNCTIME,
                                PID,
                                NAME,
                                PHONE,
                                SEX,
                                BIRTHDAY,
                                ADDRESSINFO,
                                GROWTHVALUE,
                                POINTS,
                                ALLPOINTS,
                                AMOUNT,
                                ALLCONSUMINGAMOUNT,
                                ADDTIME,
                                STATUS,
                                AID,
                                PROVINCENAME,
                                PROVINCEID,
                                CITYNAME,
                                CITYID,
                                DISTRICTNAME,
                                DISTRICTID,
                                ADDRESS,
                                MAPTYPE,
                                LONGITUDE,
                                LATITUDE,
                                CODE,
                                SYNCFLAG,
                                NEWFLAG,
                                MEMBERCARDNO)
      SELECT /*ALL_ROWS */ DISTINCT                                            
                     '' SYNCID,
                      '' SYNCTIME,
                      V_PID pid,
                      SUBSTR (a.cmname, 1, 30),
                      a.cmmobile1,
                      DECODE (a.cmsex, 'M', 1, 0) sex,
                      cmbirthday,
                      '' ADDRESSINFO,
                      '' GROWTHVALUE,
                      b.ctotjfye,
                      b.ctotjfye,
                      '' AMOUNT,
                      '' ALLCONSUMINGAMOUNT,
                      '' ADDTIME,
                      0 STATUS,
                      '' AID,
                      a.cmadd1 PROVINCENAME,
                      '' PROVINCEID,
                      a.CMADD2 CITYNAME,
                      '' CITYID,
                      SUBSTR (a.CMADD3, 1, 20) DISTRICTNAME,
                      '' DISTRICTID,
                      a.cmaddr ADDRESS,
                      '' MAPTYPE,
                      '' LONGITUDE,
                      '' LATITUDE,
                      a.cmzip CODE,
                      0 SYNCFLAG,
                      1 NEWFLAG,
                      d.cdmno cardno
        FROM CUSTMEMBER a, CUSTOMER b, Cardmain d
       WHERE     a.cmcustid = b.cid
             AND d.Cdmcid = a.cmmemid
             AND d.Cdmstatus = 'Y'
             AND d.CDMMKT = a.CMMKT
             AND LENGTH (a.CMMOBILE1) = 11
             AND trim(a.cmname) is not null
             AND CDMFLAG='04' and d.cdmtype='BBHY'
             and not exists(select 1 from wmofflinevsonline
                 where pid = V_PID  AND wmmembercardno =d.Cdmcid)
             and not exists (select 1 from WMOffLineMember e
                where e.pid=V_PID and    d.cdmno=e.MEMBERCARDNO);

   PRC_LOG (2,
            V_SUCCESS,
            V_OPR,
            '2',
            '2 写入实体店会员表   SUCCESS!!');


-- wmofflinevsonline   '微盟线下线上会员号对应表表';
         --根据手机号，匹配线上、现下会员到对应表　
         
                INSERT INTO wmofflinevsonline
                      (pid, 
                       membercardno, 
                       wmmembercardno, 
                       dt)
                  SELECT V_PID,a.cmcustid, m.membercardno,sysdate
                    FROM CUSTMEMBER a,WMMember m
                   WHERE m.pid=V_PID
                         and a.cmmobile1 = m.membercardno
                         and not exists (select 1 from wmofflinevsonline c 
                         where c.pid=V_PID and c.wmmembercardno=m.membercardno) ; 

   PRC_LOG (3,
            V_SUCCESS,
            V_OPR,
            '2',
            '3 写入wmofflinevsonline   SUCCESS!!');
            
--更新实体店信息,只更新姓名、积分、省市区，地址，同步标志，是否新增
                UPDATE WMOffLineMember cc
                   SET (NAME,
                        POINTS,
                        ALLPOINTS,
                        PROVINCENAME,
                        CITYNAME,
                        DISTRICTNAME,
                        ADDRESS,
                        SYNCFLAG, NEWFLAG) =
                          (SELECT  /*ALL_ROWS */ SUBSTR (a.cmname, 1, 30),
                                           b.ctotjfye,
                                           b.ctotjfye,
                                           a.cmadd1  ,
                                           a.CMADD2  ,
                                           SUBSTR (a.CMADD3, 1, 20)  ,
                                           a.cmaddr  ,0,0
                             FROM CUSTMEMBER a, CUSTOMER b, Cardmain d
                            WHERE     a.cmcustid = b.cid
                                  AND d.Cdmcid = a.cmmemid
                                  AND d.Cdmstatus = 'Y'
                                  AND d.CDMMKT = a.CMMKT  
                                  AND d.CDMFLAG = '04'
                                  AND d.cdmtype = 'BBHY'
                                  and cc.pid=V_PID
                                  and cc.membercardno=D.cdmno 
                                   and (cc.POINTS<> b.ctotjfye or cc.name<>SUBSTR (a.cmname, 1, 30) or cc.ADDRESS<> a.cmaddr) 
                            )
                 WHERE     EXISTS
                              (SELECT 1
                                 FROM CUSTMEMBER aa, CUSTOMER bb, Cardmain dd
                                WHERE     aa.cmcustid = bb.cid
                                      AND dd.Cdmcid = aa.cmmemid
                                      AND dd.Cdmstatus = 'Y'
                                      AND dd.CDMMKT = aa.CMMKT  
                                      AND dd.CDMFLAG = '04'
                                      AND dd.cdmtype = 'BBHY'
                                  and cc.pid=V_PID
                                  and cc.membercardno=DD.cdmno 
                                   and (cc.POINTS<> bb.ctotjfye or cc.name<>SUBSTR (aa.cmname, 1, 30) or cc.ADDRESS<> aa.cmaddr))
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM wmofflinevsonline w
                                WHERE pid = V_PID AND w.wmmembercardno = cc.phone)
                       and SYNCFLAG=1 and NEWFLAG=1;
                      
   PRC_LOG (4,
            V_SUCCESS,
            V_OPR,
            '2',
            '4 写入更新实体店信息,姓名、积分、省市区，地址 SUCCESS!!');            
         

        --写入微盟流水表
        INSERT INTO wmofflinepointslog (SYNCID,
                                        SYNCTIME,
                                        PID,
                                        MEMBERCARDNO,
                                        WMMEMBERCARDNO,
                                        POINTS,
                                        STOREID,
                                        TITLE,
                                        REMARK,
                                        ISABOUTGROWTHVALUE,
                                        OPERATOR,
                                        POINTSPAYTYPE,
                                        SYNCFLAG,
                                        ID)
           SELECT '',
                  '',
                  b.pid,
                  '' MEMBERCARDNO,
                  b.wmMEMBERCARDNO,
                  a.jf,
                  REPLACE (LPAD (c.storeid, 4), ' ', '0'),
                  '线下消费',
                  '',
                  '',
                  'WMUP',
                  '',
                  0,
                  a.CDLSEQNO
             FROM HY_WM_JFHZ a, wmofflinevsonline b, wmgzh c
            WHERE     b.pid = a.pid
                  AND a.cdlcid = b.membercardno
                  AND c.pid = b.pid
                  AND b.pid = V_PID;
                  
                  
   PRC_LOG (5,
            V_SUCCESS,
            V_OPR,
            '2',
            '5 写入微盟流水表   SUCCESS  ＴＨＥ　ＥＮＤ !!');


   OUTSTATUS := 0;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;

      OUTSTATUS := SQLCODE;
      RETURN;
END PRC_ToWmmember_middleTab;
 
