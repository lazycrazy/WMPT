drop table wmusers;
drop table wmapps;
drop table wmgzh;
drop table wmpointslog;
drop table wmmember;
drop table wmofflinemember;
drop table wmofflinepointslog;
drop table wmofflinevsonline;
drop table wmsync;
drop sequence wmUSERS_ID_SEQ;
drop sequence WMAPPS_ID_SEQ;
drop sequence WMSYNC_ID_SEQ ;
 

			 

INSERT INTO WMAPPS (ID,
                    APPID,
                    CLIENT_ID,
                    CLIENT_SECRET,
                    NAME)
     VALUES (WMAPPS_ID_SEQ.nextval,
             'C684D292348F43A9F86DE18F7119C1D4',
             'C684D292348F43A9F86DE18F7119C1D4',
             '15E675D5A9C3F5F5E68DDE6E6660D076',
             '会员同步');

create sequence wmUSERS_ID_SEQ
minvalue 1        --最小值
nomaxvalue        --不设置最大值
start with 1      --从1开始计数
increment by 1    --每次加1个
nocycle           --一直累加，不循环
nocache          --不建缓冲区
;

--
-- USERS  (Table) 
--
CREATE TABLE wmUSERS
(
  ID              INTEGER                       NOT NULL,
  NAME            VARCHAR2(255 BYTE)            NOT NULL,
  HASHEDPASSWORD  VARCHAR2(50 BYTE)             NOT NULL,
  LASTLOGIN       DATE,
  CREATEDAT       DATE default sysdate,
  UPDATEDAT       DATE,
  TOKEN           VARCHAR2(255 BYTE),
  ISBANNED        CHAR(1 BYTE)        DEFAULT '0'               NOT NULL
);



-- 
-- Non Foreign Key Constraints for Table USERS 
-- 
ALTER TABLE wmUSERS ADD (
  CONSTRAINT wmUSERS_PK
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);

 

  create sequence WMAPPS_ID_SEQ
minvalue 1        --最小值
nomaxvalue        --不设置最大值
start with 1      --从1开始计数
increment by 1    --每次加1个
nocycle           --一直累加，不循环
nocache          --不建缓冲区
;
--微盟APP应用
  CREATE TABLE  WMAPPS
(
  ID             INTEGER                        NOT NULL,
  APPID          VARCHAR2(32),
  CLIENT_ID      VARCHAR2(32)                   NOT NULL,
  CLIENT_SECRET  VARCHAR2(32)                   NOT NULL,
  NAME           VARCHAR2(128)
);


ALTER TABLE WMAPPS ADD (
  CONSTRAINT WMAPPS_PK
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);


COMMENT ON TABLE WMAPPS IS '微盟平台应用表';

COMMENT ON COLUMN WMAPPS.APPID IS '微盟平台应用APPID';

COMMENT ON COLUMN WMAPPS.CLIENT_ID IS '应用证书ID';

COMMENT ON COLUMN WMAPPS.CLIENT_SECRET IS '应用证书密码';

COMMENT ON COLUMN WMAPPS.NAME IS '应用名称';

   --公众号平台
  CREATE TABLE  WMGZH
( 
  CLIENT_ID VARCHAR2(32),
  PID          VARCHAR2(20) not null,
   NAME           VARCHAR2(128),
  avatarUrl      VARCHAR2(256)                  ,
  access_token  VARCHAR2(36)                   NOT NULL,
 refresh_token VARCHAR2(36)                   NOT NULL
);


ALTER TABLE WMGZH ADD (
  CONSTRAINT WMGZH_PK
  PRIMARY KEY
  (PID)
  ENABLE VALIDATE);
COMMENT ON TABLE WMGZH IS '微盟公众号';
COMMENT ON COLUMN WMGZH.CLIENT_ID IS '应用证书ID';
COMMENT ON COLUMN WMGZH.PID IS '公众号平台ID';
COMMENT ON COLUMN WMGZH.NAME IS '公众号平台名称';
COMMENT ON COLUMN WMGZH.avatarUrl IS '公众号平台头像地址';
COMMENT ON COLUMN WMGZH.access_token IS '访问钥匙';
COMMENT ON COLUMN WMGZH.refresh_token IS '刷新钥匙';



  create sequence WMSYNC_ID_SEQ
minvalue 1        --最小值
nomaxvalue        --不设置最大值
start with 1      --从1开始计数
increment by 1    --每次加1个
nocycle           --一直累加，不循环
nocache;   

--微盟同步记录表
  CREATE TABLE WMSYNC
(
   ID     INTEGER NOT NULL,
   PID  VARCHAR2(20) not null,
   synctype char(1),
   synctime   DATE default sysdate NOT NULL,
   effectmembercount integer,
   status integer,
   remark varchar2(256)
);


ALTER TABLE WMSYNC ADD (
  CONSTRAINT WMSYNC_PK
  PRIMARY KEY
  (ID)
  ENABLE VALIDATE);
COMMENT ON TABLE WMSYNC IS '微盟同步记录表';
COMMENT ON COLUMN WMSYNC.ID IS 'ID';
COMMENT ON COLUMN WMSYNC.PID IS '公众号平台ID';
COMMENT ON COLUMN WMSYNC.synctype IS '同步类型：0上传1下载';
COMMENT ON COLUMN WMSYNC.synctime IS '同步时间';
COMMENT ON COLUMN WMSYNC.effectmembercount IS '影响会员行数';
COMMENT ON COLUMN WMSYNC.status IS '状态0-开始1-成功-1失败';
COMMENT ON COLUMN WMSYNC.remark IS '备注';

--微盟会员积分流水
CREATE TABLE WMPointslog
(
PID  VARCHAR2(20) not null,
   ID              NUMBER NOT NULL,
   memberCardNo    VARCHAR2 (50) NOT NULL,
   name            VARCHAR2 (50),
   phone           VARCHAR2 (20),
   title           VARCHAR2 (60),
   storeId         NUMBER,
   storeName       VARCHAR2 (60),
   points          INTEGER,
   TIme            NUMBER,
   pointsPayType   INTEGER,
   addOrReduce     INTEGER,
   operator        VARCHAR2 (50),
   remark          VARCHAR2 (200),
   syncflag char(1) not null, 
   syncid integer ,
   synctime date
);

COMMENT ON TABLE WMPointslog IS '微盟会员积分流水';
COMMENT ON COLUMN WMPointslog.PID IS '公众号平台ID';
COMMENT ON COLUMN WMPointslog.ID IS '微盟积分流水标识Id';
COMMENT ON COLUMN WMPointslog.memberCardNo IS '会员卡号'; 
COMMENT ON COLUMN WMPointslog.name         IS '会员姓名';
COMMENT ON COLUMN WMPointslog.title         IS '交易名称';
COMMENT ON COLUMN WMPointslog.storeId         IS '门店Id 0 表示总店';
COMMENT ON COLUMN WMPointslog.storeName         IS '门店名称';
COMMENT ON COLUMN WMPointslog.points         IS '交易积分数';
COMMENT ON COLUMN WMPointslog.time         IS '变动时间时间戳';
COMMENT ON COLUMN WMPointslog.pointsPayType        IS '支付方式 未知 = 0, 消费赠送 = 1,兑换使用 = 2,节日赠送 = 3,活动赠送 = 4,手动增加 = 5,手动扣除 = 6,签到赠送 = 7,分享赠送 COMMENT ON COLUMN WMPointslog.= 8,消费使用 = 9,开卡赠送 = 10,充值赠送 = 11,积分规则扣除 = 12';
COMMENT ON COLUMN WMPointslog.addOrReduce         IS '增加还是减少 0表示增加 1表示减少';
COMMENT ON COLUMN WMPointslog.operator         IS '操作人';
COMMENT ON COLUMN WMPointslog.remark         IS '备注';
COMMENT ON COLUMN WMPointslog.syncflag         IS '同步标记0-未同步1-已同步';
COMMENT ON COLUMN WMPointslog.syncid         IS '同步处理ID';
COMMENT ON COLUMN WMPointslog.synctime         IS '同步时间'; 
--微盟会员表
CREATE TABLE WMMember
(
PID  VARCHAR2(20) not null,
   syncid integer ,
   synctime date,
   aID                      NUMBER,
   openid                   VARCHAR2 (50),
   weimobopenId             VARCHAR2 (50),
   memberCardNo             VARCHAR2 (50),
   name                     VARCHAR2 (50),
   nickname                 VARCHAR2 (50),
   headUrl                  VARCHAR2 (200),
   phone                    VARCHAR2 (20),
   sex                      INTEGER,
   birthday                 VARCHAR2 (30),
   email                    VARCHAR2 (50),
   degree                   INTEGER,
   profession               INTEGER,
   income                   INTEGER,
   hobby                    VARCHAR2 (80),
   addressInfo              VARCHAR2 (300),
   growthValue              INTEGER,
   points                   INTEGER,
   amount                   NUMBER,
   allConsumingamount       NUMBER,
   balanceConsumingamount   NUMBER,
   consumingCount           INTEGER,
   perConsumingamount       NUMBER,
   allpoints                NUMBER,
   lastConsumingTime        VARCHAR2 (30),
   activateTime             NUMBER,
   disCount                 NUMBER,
   tags                     VARCHAR2 (120),
   qrcodeUrl                VARCHAR2 (200),
   barcodeUrl               VARCHAR2 (200),
   weiChatcode              VARCHAR2 (50),
   passWord                 VARCHAR2 (16),
   "LEVEL"                    VARCHAR2 (120),
   memberStatus             INTEGER,
   isNeedSyncWeiXin         CHAR (1),
   entityStatus             INTEGER,
   startDate                NUMBER,
   expireDate               NUMBER,
   id                       NUMBER,
   birthdayDay              INTEGER,
   birthdayMonth            INTEGER,
   canUseStoreIds           VARCHAR2 (120),
   canUseStoreType          INTEGER,
   fromValue                VARCHAR2 (60),
   provinceName             VARCHAR2 (60),
   provinceId               VARCHAR2 (60),
   cityName                 VARCHAR2 (100),
   cityId                   VARCHAR2 (20),
   districtName             VARCHAR2 (20),
   districtId               VARCHAR2 (20),
   address                  VARCHAR2 (120),
   mapType                  INTEGER,
   longitude                NUMBER,
   latitude                 NUMBER,
   code                     VARCHAR2 (10)
);

COMMENT ON TABLE WMMember IS '微盟会员表';
COMMENT ON COLUMN WMMember.PID IS '公众号平台ID';
COMMENT ON COLUMN WMMember.syncid         IS '同步处理ID';
COMMENT ON COLUMN WMMember.synctime         IS '同步时间'; 
COMMENT ON COLUMN WMMember.aid   IS '商户id';
 COMMENT ON COLUMN WMMember.openId   IS '用户openId';
 COMMENT ON COLUMN WMMember.weimobopenId   IS '用户托管授权微盟weimobopenId';
 COMMENT ON COLUMN WMMember.memberCardNo   IS '会员卡号';
 COMMENT ON COLUMN WMMember.name   IS '会员姓名';
 COMMENT ON COLUMN WMMember.nickName   IS '昵称(备注名)';
 COMMENT ON COLUMN WMMember.headUrl   IS '头像';
 COMMENT ON COLUMN WMMember.phone   IS '手机号';
 COMMENT ON COLUMN WMMember.sex   IS '性别  不详 = 0, 男 = 1,女 = 2';
 COMMENT ON COLUMN WMMember.birthday   IS '生日时间戳 没有生日信息时为空orNulll 否则是时间戳';
 COMMENT ON COLUMN WMMember.eMail   IS '邮箱';
 COMMENT ON COLUMN WMMember.degree   IS '学历 不适用 = 0,小学 = 1,初中 = 2,高中 = 3,大专 = 4,大学 = 5,研究生 = 6';
 COMMENT ON COLUMN WMMember.profession   IS '行业 未知 = 0,IT/互联网/通信/电子= 1,金融/投资/财会=2,广告/媒体/出版/艺术 = 3,市场/销售/客服=4,人事/行政/管理= 5,建筑/房产/物业= 6,消费品/贸易/物流= 7,咨询/法律/认证= 8,生产/制造/营运/采购= 9,生物/制药/医疗/护理 = 10,教育/培训/翻译= 11,科研/环保/休闲/其他= 12';
 COMMENT ON COLUMN WMMember.income   IS '收入 5万以下= 0,5-15万 = 1,15万-30万= 2,30万以上 = 3';
 COMMENT ON COLUMN WMMember.hobby   IS '爱好 其他 = 0,游戏 = 1,阅读 = 2,音乐 = 3,运动 = 4,动漫 = 5,旅行 = 6,家居 = 7,曲艺 = 8,宠物 = 9,娱乐 = 10, 电影 = 11,电视剧 = 12,健康养生 = 13,数码 = 14,美食 = 15';
-- COMMENT ON COLUMN WMMember.listOther   IS '自定义条件';
 COMMENT ON COLUMN WMMember.addressInfo   IS '会员地址信息,值参考旺铺行政区区域数据';
 COMMENT ON COLUMN WMMember.growthValue   IS '会员成长值';
 COMMENT ON COLUMN WMMember.poInts   IS '当前积分数量';
 COMMENT ON COLUMN WMMember.amount   IS '当前余额';
 COMMENT ON COLUMN WMMember.allConsumingAmount   IS '累计消费';
 COMMENT ON COLUMN WMMember.balanceConsumingAmount   IS '累计余额消费';
 COMMENT ON COLUMN WMMember.consumingCount   IS '消费次数';
 COMMENT ON COLUMN WMMember.perConsumingAmount   IS '客单价';
 COMMENT ON COLUMN WMMember.allPoInts   IS '累计积分';
 COMMENT ON COLUMN WMMember.lastConsumingTime   IS '最近一次消费时间时间戳 没有信息时为空orNulll 否则是时间戳';
 COMMENT ON COLUMN WMMember.activateTime   IS '激活时间';
 COMMENT ON COLUMN WMMember.disCount   IS '会员享受的折扣';
 COMMENT ON COLUMN WMMember.tags   IS '会员标签Id和名称';
 COMMENT ON COLUMN WMMember.qrcodeUrl   IS '会员二维码地址';
 COMMENT ON COLUMN WMMember.barcodeUrl   IS '会员条形码地址';
 COMMENT ON COLUMN WMMember.weiChatCode   IS '微信code';
 COMMENT ON COLUMN WMMember.passWord   IS '密码';
 COMMENT ON COLUMN WMMember."LEVEL"   IS '等级编号和名称';
 COMMENT ON COLUMN WMMember.memberStatus   IS '会员状态已领卡 = 0, 生效中 = 1, 已冻结 = 2, 已过期 = 3,未开始 = 4';
 COMMENT ON COLUMN WMMember.isNeedSyncWeiXin   IS '是否需要同步微信';
-- COMMENT ON COLUMN WMMember.fromType   IS '会员来源 0 未知';
 COMMENT ON COLUMN WMMember.entityStatus   IS '数据库会员状态';
 COMMENT ON COLUMN WMMember.startDate   IS '起始时间时间戳';
 COMMENT ON COLUMN WMMember.expireDate   IS '过期时间时间戳'; 
 COMMENT ON COLUMN WMMember.id   IS '标识'; 
 COMMENT ON COLUMN WMMember.provinceName   IS '省名称';
 COMMENT ON COLUMN WMMember.provinceId   IS '省Id';
 COMMENT ON COLUMN WMMember.cityName   IS '市名称';
 COMMENT ON COLUMN WMMember.cityId   IS '市id';
 COMMENT ON COLUMN WMMember.districtName   IS '区名称';
 COMMENT ON COLUMN WMMember.districtId   IS '区Id';
 COMMENT ON COLUMN WMMember.address   IS '详情地址';
 COMMENT ON COLUMN WMMember.mapType   IS '地图类型 Baidu = 0, Google = 1,Tencent = 2 暂时只支持Baidu';
 COMMENT ON COLUMN WMMember.Longitude   IS '经度';
 COMMENT ON COLUMN WMMember.latitude   IS '纬度';
 COMMENT ON COLUMN WMMember.code   IS '邮编';

--实体店会员表
CREATE TABLE WMOffLineMember
(
syncid integer,
synctime date,
PID  VARCHAR2(20) not null,
   name                 VARCHAR2 (50),
   phone                VARCHAR2 (20),
   sex                  INTEGER,
   birthday             VARCHAR2 (30),
   addressinfo          VARCHAR2 (300),
   growthValue          INTEGER,
   points               INTEGER,
   allpoints            NUMBER,
   amount               NUMBER,
   allConsumingamount   NUMBER,
   addTime              NUMBER,
   status               INTEGER,
   aid                  NUMBER,
   provinceName         VARCHAR2 (60),
   provinceId           VARCHAR2 (60),
   cityName             VARCHAR2 (100),
   cityId               VARCHAR2 (20),
   districtName         VARCHAR2 (20),
   districtId           VARCHAR2 (20),
   address              VARCHAR2 (120),
   mapType              INTEGER,
   longitude            NUMBER,
   latitude             NUMBER,
   code                 VARCHAR2 (10),
   syncflag             CHAR (1) not null,                                  
   newflag char(1), 
   membercardno         VARCHAR2 (30)                                 
);
COMMENT ON TABLE WMOffLineMember IS '微盟线下线上会员号对应表';
COMMENT ON COLUMN WMOffLineMember.syncid IS '同步处理ID';
COMMENT ON COLUMN WMOffLineMember.synctime IS '同步时间';
COMMENT ON COLUMN WMOffLineMember.PID IS '公众号平台ID';
COMMENT ON COLUMN WMOffLineMember.name   IS '会员姓名';
 COMMENT ON COLUMN WMOffLineMember.phone   IS '手机号';
 COMMENT ON COLUMN WMOffLineMember.sex   IS '性别 不详 = 0,男 = 1,女 = 2';
 COMMENT ON COLUMN WMOffLineMember.birthday   IS '生日时间戳';
 COMMENT ON COLUMN WMOffLineMember.address   IS '地址信息';
 COMMENT ON COLUMN WMOffLineMember.growthValue   IS '成长值';
 COMMENT ON COLUMN WMOffLineMember.points   IS '可用积分';
 COMMENT ON COLUMN WMOffLineMember.allPoints   IS '累计积分';
 COMMENT ON COLUMN WMOffLineMember.amount   IS '可用余额';
 COMMENT ON COLUMN WMOffLineMember.allConsumingAmount   IS '累计消费';
 COMMENT ON COLUMN WMOffLineMember.addTime   IS '添加时间时间戳';
 COMMENT ON COLUMN WMOffLineMember.status   IS '0未绑定微盟会员号1已绑定微盟会员号';
 COMMENT ON COLUMN WMOffLineMember.aid   IS '商户Id';
 COMMENT ON COLUMN WMOffLineMember.provinceName   IS '省名称';
 COMMENT ON COLUMN WMOffLineMember.provinceId   IS '省Id';
 COMMENT ON COLUMN WMOffLineMember.cityName   IS '市名称';
 COMMENT ON COLUMN WMOffLineMember.cityId   IS '市Id';
 COMMENT ON COLUMN WMOffLineMember.districtName   IS '区名称';
 COMMENT ON COLUMN WMOffLineMember.districtId   IS '区Id';
 COMMENT ON COLUMN WMOffLineMember.address   IS '详情地址';
 COMMENT ON COLUMN WMOffLineMember.mapType   IS '地图类型 0 Baidu 1 Google 2 Tencent';
 COMMENT ON COLUMN WMOffLineMember.longitude   IS '经度';
 COMMENT ON COLUMN WMOffLineMember.latitude   IS '纬度';
 COMMENT ON COLUMN WMOffLineMember.code   IS '邮编';
  COMMENT ON COLUMN WMOffLineMember.syncflag   IS '是否已同步到微盟0-未1-已';
   COMMENT ON COLUMN WMOffLineMember.newflag   IS '新增标记，线下新增的会员';
    COMMENT ON COLUMN WMOffLineMember.membercardno   IS '惠友会员卡号';


--实体店会员积分流水

CREATE TABLE wmofflinepointslog
(
syncid integer,
synctime date,
PID  VARCHAR2(20) not null,
membercardno VARCHAR2 (30) ,
wmmembercardno  VARCHAR2 (30) not null,
   points          INTEGER,
   storeId         NUMBER,
   title           VARCHAR2 (60),
   remark          VARCHAR2 (200),
   isAboutGrowthValue char(1),
    operator        VARCHAR2 (50),
    pointsPayType integer ,
    syncflag char(1) not null,
	id integer
);
COMMENT ON TABLE wmofflinepointslog IS '线下会员积分变更流水';
COMMENT ON COLUMN wmofflinepointslog.syncid IS '同步处理ID';
COMMENT ON COLUMN wmofflinepointslog.synctime IS '同步时间';
COMMENT ON COLUMN wmofflinepointslog.PID IS '公众号平台ID';
COMMENT ON COLUMN wmofflinepointslog.membercardno IS '线下会员号';
COMMENT ON COLUMN wmofflinepointslog.wmmembercardno IS '微盟会员号';
COMMENT ON COLUMN wmofflinepointslog.points IS '积分';
COMMENT ON COLUMN wmofflinepointslog.storeId IS '店铺ID';
COMMENT ON COLUMN wmofflinepointslog.title IS '标题';
COMMENT ON COLUMN wmofflinepointslog.remark IS '备注';
COMMENT ON COLUMN wmofflinepointslog.isAboutGrowthValue IS '是否关联成长值0FALSE1true';
COMMENT ON COLUMN wmofflinepointslog.operator IS '操作人';
COMMENT ON COLUMN wmofflinepointslog.pointsPayType IS '交易方式 未知 = 0,消费赠送 = 1,兑换使用 = 2,节日赠送 = 3,活动赠送 = 4,手动增加 = 5,手动扣除 = 6,签到赠送 = 7,分享赠送 = 8, 消费使用 = 9,开卡赠送 = 10,充值赠送 = 11,积分规则扣除 = 12';
COMMENT ON COLUMN wmofflinepointslog.syncflag IS '同步标记0 未同步 --1已同步';
COMMENT ON COLUMN wmofflinepointslog.id IS '积分流水标识';

create table wmofflinevsonline(
PID  VARCHAR2(20) not null,
membercardno VARCHAR2 (30) not null,
wmmembercardno  VARCHAR2 (30) not null
);

COMMENT ON TABLE wmofflinevsonline IS '微盟线下线上会员号对应表表';
COMMENT ON COLUMN wmofflinevsonline.PID IS '公众号平台ID';
COMMENT ON COLUMN wmofflinevsonline.membercardno IS '线下会员号';
COMMENT ON COLUMN wmofflinevsonline.wmmembercardno IS '微盟会员号';