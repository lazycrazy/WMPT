CREATE OR REPLACE PROCEDURE PRC_Wmmember_IMPORT (V_PID       IN     VARCHAR,
                                                 OUTSTATUS      OUT INTEGER)
AS
   --���̺�
   V_storeID         VARCHAR (10);
   V_membercardno    VARCHAR (20);                                        --��Ա
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
   CARDNO            VARCHAR2 (30);                                     --���ؿ���
   CARDID            VARCHAR2 (30);

   V_title           VARCHAR2 (30);                                   --�����������
   V_posints         NUMBER;                                           --�������ֵ
   V_time            VARCHAR2 (30);
   V_pointspaytype   VARCHAR2 (5);                                    --���ֱ������
   V_operator        VARCHAR2 (30);                                      --������
   V_ADDORREDUCE     VARCHAR (2);                                     --���ֲ�������
   V_CID             VARCHAR (30) := '';                                --��ԱID
   V_allPoInts       number;                                            --��Ա����
   
   --ȡ΢�˽ӿڱ��Ա
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
   --ȡ΢�˽ӿڱ��Ա����
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


   --΢�˻�Ա��
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
               --���ӻ�Ա����Ա����
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

         -- wmofflinevsonline   '΢���������ϻ�Ա�Ŷ�Ӧ���';
         --�����ֻ��ţ�ƥ�����ϡ����»�Ա����Ӧ��
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

         --'΢�˻�Ա������ˮ';
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
                     --���ϻ��ּ�¼ͬ��������
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
         
         --��д����ͬ����־      
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
   --���̺�
   --V_storeID         VARCHAR (10);                               --��Ա
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

    --д��ʵ����Ա��
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
            '2 д��ʵ����Ա��   SUCCESS!!');


-- wmofflinevsonline   '΢���������ϻ�Ա�Ŷ�Ӧ���';
         --�����ֻ��ţ�ƥ�����ϡ����»�Ա����Ӧ��
         
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
            '3 д��wmofflinevsonline   SUCCESS!!');
            
--����ʵ�����Ϣ,ֻ�������������֡�ʡ��������ַ��ͬ����־���Ƿ�����
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
            '4 д�����ʵ�����Ϣ,���������֡�ʡ��������ַ SUCCESS!!');            
         

        --д��΢����ˮ��
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
                  '��������',
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
            '5 д��΢����ˮ��   SUCCESS  �ԣȣš��ţΣ� !!');


   OUTSTATUS := 0;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;

      OUTSTATUS := SQLCODE;
      RETURN;
END PRC_ToWmmember_middleTab;
 
