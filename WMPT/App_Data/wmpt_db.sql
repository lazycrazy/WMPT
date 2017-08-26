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









-- Create table
create table WMMEMBER
(
  PID                    VARCHAR2(20) not null,
  SYNCID                 INTEGER,
  SYNCTIME               DATE,
  AID                    NUMBER,
  OPENID                 VARCHAR2(50),
  WEIMOBOPENID           VARCHAR2(50),
  MEMBERCARDNO           VARCHAR2(50) not null,
  NAME                   VARCHAR2(50),
  NICKNAME               VARCHAR2(50),
  HEADURL                VARCHAR2(200),
  PHONE                  VARCHAR2(20),
  SEX                    INTEGER,
  BIRTHDAY               VARCHAR2(30),
  EMAIL                  VARCHAR2(50),
  DEGREE                 INTEGER,
  PROFESSION             INTEGER,
  INCOME                 INTEGER,
  HOBBY                  VARCHAR2(80),
  ADDRESSINFO            VARCHAR2(300),
  GROWTHVALUE            INTEGER,
  POINTS                 INTEGER,
  AMOUNT                 NUMBER,
  ALLCONSUMINGAMOUNT     NUMBER,
  BALANCECONSUMINGAMOUNT NUMBER,
  CONSUMINGCOUNT         INTEGER,
  PERCONSUMINGAMOUNT     NUMBER,
  ALLPOINTS              NUMBER,
  LASTCONSUMINGTIME      VARCHAR2(30),
  ACTIVATETIME           NUMBER,
  DISCOUNT               NUMBER,
  TAGS                   VARCHAR2(120),
  QRCODEURL              VARCHAR2(200),
  BARCODEURL             VARCHAR2(200),
  WEICHATCODE            VARCHAR2(50),
  PASSWORD               VARCHAR2(16),
  LEVEL                  VARCHAR2(120),
  MEMBERSTATUS           INTEGER,
  ISNEEDSYNCWEIXIN       CHAR(1),
  ENTITYSTATUS           INTEGER,
  STARTDATE              NUMBER,
  EXPIREDATE             NUMBER,
  ID                     NUMBER,
  BIRTHDAYDAY            INTEGER,
  BIRTHDAYMONTH          INTEGER,
  CANUSESTOREIDS         VARCHAR2(120),
  CANUSESTORETYPE        INTEGER,
  FROMVALUE              VARCHAR2(60),
  PROVINCENAME           VARCHAR2(60),
  PROVINCEID             VARCHAR2(60),
  CITYNAME               VARCHAR2(100),
  CITYID                 VARCHAR2(20),
  DISTRICTNAME           VARCHAR2(20),
  DISTRICTID             VARCHAR2(20),
  ADDRESS                VARCHAR2(120),
  MAPTYPE                INTEGER,
  LONGITUDE              NUMBER,
  LATITUDE               NUMBER,
  CODE                   VARCHAR2(10)
)
tablespace DATA_SPC
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table WMMEMBER
  is '微盟会员表';
-- Add comments to the columns 
comment on column WMMEMBER.PID
  is '公众号平台ID';
comment on column WMMEMBER.SYNCID
  is '同步处理ID';
comment on column WMMEMBER.SYNCTIME
  is '同步时间';
comment on column WMMEMBER.AID
  is '商户id';
comment on column WMMEMBER.OPENID
  is '用户openId';
comment on column WMMEMBER.WEIMOBOPENID
  is '用户托管授权微盟weimobopenId';
comment on column WMMEMBER.MEMBERCARDNO
  is '会员卡号';
comment on column WMMEMBER.NAME
  is '会员姓名';
comment on column WMMEMBER.NICKNAME
  is '昵称(备注名)';
comment on column WMMEMBER.HEADURL
  is '头像';
comment on column WMMEMBER.PHONE
  is '手机号';
comment on column WMMEMBER.SEX
  is '性别  不详 = 0, 男 = 1,女 = 2';
comment on column WMMEMBER.BIRTHDAY
  is '生日时间戳 没有生日信息时为空orNulll 否则是时间戳';
comment on column WMMEMBER.EMAIL
  is '邮箱';
comment on column WMMEMBER.DEGREE
  is '学历 不适用 = 0,小学 = 1,初中 = 2,高中 = 3,大专 = 4,大学 = 5,研究生 = 6';
comment on column WMMEMBER.PROFESSION
  is '行业 未知 = 0,IT/互联网/通信/电子= 1,金融/投资/财会=2,广告/媒体/出版/艺术 = 3,市场/销售/客服=4,人事/行政/管理= 5,建筑/房产/物业= 6,消费品/贸易/物流= 7,咨询/法律/认证= 8,生产/制造/营运/采购= 9,生物/制药/医疗/护理 = 10,教育/培训/翻译= 11,科研/环保/休闲/其他= 12';
comment on column WMMEMBER.INCOME
  is '收入 5万以下= 0,5-15万 = 1,15万-30万= 2,30万以上 = 3';
comment on column WMMEMBER.HOBBY
  is '爱好 其他 = 0,游戏 = 1,阅读 = 2,音乐 = 3,运动 = 4,动漫 = 5,旅行 = 6,家居 = 7,曲艺 = 8,宠物 = 9,娱乐 = 10, 电影 = 11,电视剧 = 12,健康养生 = 13,数码 = 14,美食 = 15';
comment on column WMMEMBER.ADDRESSINFO
  is '会员地址信息,值参考旺铺行政区区域数据';
comment on column WMMEMBER.GROWTHVALUE
  is '会员成长值';
comment on column WMMEMBER.POINTS
  is '当前积分数量';
comment on column WMMEMBER.AMOUNT
  is '当前余额';
comment on column WMMEMBER.ALLCONSUMINGAMOUNT
  is '累计消费';
comment on column WMMEMBER.BALANCECONSUMINGAMOUNT
  is '累计余额消费';
comment on column WMMEMBER.CONSUMINGCOUNT
  is '消费次数';
comment on column WMMEMBER.PERCONSUMINGAMOUNT
  is '客单价';
comment on column WMMEMBER.ALLPOINTS
  is '累计积分';
comment on column WMMEMBER.LASTCONSUMINGTIME
  is '最近一次消费时间时间戳 没有信息时为空orNulll 否则是时间戳';
comment on column WMMEMBER.ACTIVATETIME
  is '激活时间';
comment on column WMMEMBER.DISCOUNT
  is '会员享受的折扣';
comment on column WMMEMBER.TAGS
  is '会员标签Id和名称';
comment on column WMMEMBER.QRCODEURL
  is '会员二维码地址';
comment on column WMMEMBER.BARCODEURL
  is '会员条形码地址';
comment on column WMMEMBER.WEICHATCODE
  is '微信code';
comment on column WMMEMBER.PASSWORD
  is '密码';
comment on column WMMEMBER.LEVEL
  is '等级编号和名称';
comment on column WMMEMBER.MEMBERSTATUS
  is '会员状态已领卡 = 0, 生效中 = 1, 已冻结 = 2, 已过期 = 3,未开始 = 4';
comment on column WMMEMBER.ISNEEDSYNCWEIXIN
  is '是否需要同步微信';
comment on column WMMEMBER.ENTITYSTATUS
  is '数据库会员状态';
comment on column WMMEMBER.STARTDATE
  is '起始时间时间戳';
comment on column WMMEMBER.EXPIREDATE
  is '过期时间时间戳';
comment on column WMMEMBER.ID
  is '标识';
comment on column WMMEMBER.PROVINCENAME
  is '省名称';
comment on column WMMEMBER.PROVINCEID
  is '省Id';
comment on column WMMEMBER.CITYNAME
  is '市名称';
comment on column WMMEMBER.CITYID
  is '市id';
comment on column WMMEMBER.DISTRICTNAME
  is '区名称';
comment on column WMMEMBER.DISTRICTID
  is '区Id';
comment on column WMMEMBER.ADDRESS
  is '详情地址';
comment on column WMMEMBER.MAPTYPE
  is '地图类型 Baidu = 0, Google = 1,Tencent = 2 暂时只支持Baidu';
comment on column WMMEMBER.LONGITUDE
  is '经度';
comment on column WMMEMBER.LATITUDE
  is '纬度';
comment on column WMMEMBER.CODE
  is '邮编';
-- Create/Recreate primary, unique and foreign key constraints 
alter table WMMEMBER
  add constraint PK primary key (PID, MEMBERCARDNO)
  using index 
  tablespace DATA_SPC
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

-- Create table
create table WMPOINTSLOG
(
  PID           VARCHAR2(20) not null,
  ID            NUMBER not null,
  MEMBERCARDNO  VARCHAR2(50) not null,
  NAME          VARCHAR2(50),
  PHONE         VARCHAR2(20),
  TITLE         VARCHAR2(60),
  STOREID       NUMBER,
  STORENAME     VARCHAR2(60),
  POINTS        INTEGER,
  TIME          NUMBER,
  POINTSPAYTYPE INTEGER,
  ADDORREDUCE   INTEGER,
  OPERATOR      VARCHAR2(50),
  REMARK        VARCHAR2(200),
  SYNCFLAG      CHAR(1) not null,
  SYNCID        INTEGER,
  SYNCTIME      DATE
)
tablespace DATA_SPC
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table WMPOINTSLOG
  is '微盟会员积分流水';
-- Add comments to the columns 
comment on column WMPOINTSLOG.PID
  is '公众号平台ID';
comment on column WMPOINTSLOG.ID
  is '微盟积分流水标识Id';
comment on column WMPOINTSLOG.MEMBERCARDNO
  is '会员卡号';
comment on column WMPOINTSLOG.NAME
  is '会员姓名';
comment on column WMPOINTSLOG.TITLE
  is '交易名称';
comment on column WMPOINTSLOG.STOREID
  is '门店Id 0 表示总店';
comment on column WMPOINTSLOG.STORENAME
  is '门店名称';
comment on column WMPOINTSLOG.POINTS
  is '交易积分数';
comment on column WMPOINTSLOG.TIME
  is '变动时间时间戳';
comment on column WMPOINTSLOG.POINTSPAYTYPE
  is '支付方式 未知 = 0, 消费赠送 = 1,兑换使用 = 2,节日赠送 = 3,活动赠送 = 4,手动增加 = 5,手动扣除 = 6,签到赠送 = 7,分享赠送 COMMENT ON COLUMN WMPointslog.= 8,消费使用 = 9,开卡赠送 = 10,充值赠送 = 11,积分规则扣除 = 12';
comment on column WMPOINTSLOG.ADDORREDUCE
  is '增加还是减少 0表示增加 1表示减少';
comment on column WMPOINTSLOG.OPERATOR
  is '操作人';
comment on column WMPOINTSLOG.REMARK
  is '备注';
comment on column WMPOINTSLOG.SYNCFLAG
  is '同步标记0-未同步1-已同步';
comment on column WMPOINTSLOG.SYNCID
  is '同步处理ID';
comment on column WMPOINTSLOG.SYNCTIME
  is '同步时间';
-- Create/Recreate indexes 
create unique index PK_WMPOOINTLOG on WMPOINTSLOG (PID, ID)
  tablespace DATA_SPC
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

-- Create table
create table WMOFFLINEMEMBER
(
  SYNCID             INTEGER,
  SYNCTIME           DATE,
  PID                VARCHAR2(20) not null,
  NAME               VARCHAR2(50),
  PHONE              VARCHAR2(20),
  SEX                INTEGER,
  BIRTHDAY           VARCHAR2(30),
  ADDRESSINFO        VARCHAR2(300),
  GROWTHVALUE        INTEGER,
  POINTS             INTEGER,
  ALLPOINTS          NUMBER,
  AMOUNT             NUMBER,
  ALLCONSUMINGAMOUNT NUMBER,
  ADDTIME            NUMBER,
  STATUS             INTEGER,
  AID                NUMBER,
  PROVINCENAME       VARCHAR2(60),
  PROVINCEID         VARCHAR2(60),
  CITYNAME           VARCHAR2(100),
  CITYID             VARCHAR2(20),
  DISTRICTNAME       VARCHAR2(20),
  DISTRICTID         VARCHAR2(20),
  ADDRESS            VARCHAR2(120),
  MAPTYPE            INTEGER,
  LONGITUDE          NUMBER,
  LATITUDE           NUMBER,
  CODE               VARCHAR2(10),
  SYNCFLAG           CHAR(1) not null,
  NEWFLAG            CHAR(1),
  MEMBERCARDNO       VARCHAR2(30) not null
)
tablespace DATA_SPC
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table WMOFFLINEMEMBER
  is '微盟线下线上会员号对应表';
-- Add comments to the columns 
comment on column WMOFFLINEMEMBER.SYNCID
  is '同步处理ID';
comment on column WMOFFLINEMEMBER.SYNCTIME
  is '同步时间';
comment on column WMOFFLINEMEMBER.PID
  is '公众号平台ID';
comment on column WMOFFLINEMEMBER.NAME
  is '会员姓名';
comment on column WMOFFLINEMEMBER.PHONE
  is '手机号';
comment on column WMOFFLINEMEMBER.SEX
  is '性别 不详 = 0,男 = 1,女 = 2';
comment on column WMOFFLINEMEMBER.BIRTHDAY
  is '生日时间戳';
comment on column WMOFFLINEMEMBER.GROWTHVALUE
  is '成长值';
comment on column WMOFFLINEMEMBER.POINTS
  is '可用积分';
comment on column WMOFFLINEMEMBER.ALLPOINTS
  is '累计积分';
comment on column WMOFFLINEMEMBER.AMOUNT
  is '可用余额';
comment on column WMOFFLINEMEMBER.ALLCONSUMINGAMOUNT
  is '累计消费';
comment on column WMOFFLINEMEMBER.ADDTIME
  is '添加时间时间戳';
comment on column WMOFFLINEMEMBER.STATUS
  is '0未绑定微盟会员号1已绑定微盟会员号';
comment on column WMOFFLINEMEMBER.AID
  is '商户Id';
comment on column WMOFFLINEMEMBER.PROVINCENAME
  is '省名称';
comment on column WMOFFLINEMEMBER.PROVINCEID
  is '省Id';
comment on column WMOFFLINEMEMBER.CITYNAME
  is '市名称';
comment on column WMOFFLINEMEMBER.CITYID
  is '市Id';
comment on column WMOFFLINEMEMBER.DISTRICTNAME
  is '区名称';
comment on column WMOFFLINEMEMBER.DISTRICTID
  is '区Id';
comment on column WMOFFLINEMEMBER.ADDRESS
  is '详情地址';
comment on column WMOFFLINEMEMBER.MAPTYPE
  is '地图类型 0 Baidu 1 Google 2 Tencent';
comment on column WMOFFLINEMEMBER.LONGITUDE
  is '经度';
comment on column WMOFFLINEMEMBER.LATITUDE
  is '纬度';
comment on column WMOFFLINEMEMBER.CODE
  is '邮编';
comment on column WMOFFLINEMEMBER.SYNCFLAG
  is '是否已同步到微盟0-未1-已';
comment on column WMOFFLINEMEMBER.NEWFLAG
  is '新增标记，线下新增的会员';
comment on column WMOFFLINEMEMBER.MEMBERCARDNO
  is '惠友会员卡号';
-- Create/Recreate primary, unique and foreign key constraints 
alter table WMOFFLINEMEMBER
  add constraint PK_INX_WMOFFLINEMEMBER primary key (PID, MEMBERCARDNO)
  using index 
  tablespace DATA_SPC
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );

-- Create table
create table WMOFFLINEPOINTSLOG
(
  SYNCID             INTEGER,
  SYNCTIME           DATE,
  PID                VARCHAR2(20) not null,
  MEMBERCARDNO       VARCHAR2(30),
  WMMEMBERCARDNO     VARCHAR2(30) not null,
  POINTS             INTEGER,
  STOREID            VARCHAR2(10),
  TITLE              VARCHAR2(60),
  REMARK             VARCHAR2(200),
  ISABOUTGROWTHVALUE CHAR(1),
  OPERATOR           VARCHAR2(50),
  POINTSPAYTYPE      INTEGER,
  SYNCFLAG           CHAR(1) not null,
  ID                 INTEGER
)
tablespace DATA_SPC
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table WMOFFLINEPOINTSLOG
  is '线下会员积分变更流水';
-- Add comments to the columns 
comment on column WMOFFLINEPOINTSLOG.SYNCID
  is '同步处理ID';
comment on column WMOFFLINEPOINTSLOG.SYNCTIME
  is '同步时间';
comment on column WMOFFLINEPOINTSLOG.PID
  is '公众号平台ID';
comment on column WMOFFLINEPOINTSLOG.MEMBERCARDNO
  is '线下会员号';
comment on column WMOFFLINEPOINTSLOG.WMMEMBERCARDNO
  is '微盟会员号';
comment on column WMOFFLINEPOINTSLOG.POINTS
  is '积分';
comment on column WMOFFLINEPOINTSLOG.STOREID
  is '店铺ID';
comment on column WMOFFLINEPOINTSLOG.TITLE
  is '标题';
comment on column WMOFFLINEPOINTSLOG.REMARK
  is '备注';
comment on column WMOFFLINEPOINTSLOG.ISABOUTGROWTHVALUE
  is '是否关联成长值0FALSE1true';
comment on column WMOFFLINEPOINTSLOG.OPERATOR
  is '操作人';
comment on column WMOFFLINEPOINTSLOG.POINTSPAYTYPE
  is '交易方式 未知 = 0,消费赠送 = 1,兑换使用 = 2,节日赠送 = 3,活动赠送 = 4,手动增加 = 5,手动扣除 = 6,签到赠送 = 7,分享赠送 = 8, 消费使用 = 9,开卡赠送 = 10,充值赠送 = 11,积分规则扣除 = 12';
comment on column WMOFFLINEPOINTSLOG.SYNCFLAG
  is '同步标记0 未同步 --1已同步';
comment on column WMOFFLINEPOINTSLOG.ID
  is '积分流水标识';


-- Create table
create table WMOFFLINEVSONLINE
(
  PID            VARCHAR2(20) not null,
  MEMBERCARDNO   VARCHAR2(30) not null,
  WMMEMBERCARDNO VARCHAR2(30) not null,
  DT             DATE
)
tablespace DATA_SPC
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table WMOFFLINEVSONLINE
  is '微盟线下线上会员号对应表表';
-- Add comments to the columns 
comment on column WMOFFLINEVSONLINE.PID
  is '公众号平台ID';
comment on column WMOFFLINEVSONLINE.MEMBERCARDNO
  is '线下会员号';
comment on column WMOFFLINEVSONLINE.WMMEMBERCARDNO
  is '微盟会员号';
-- Create/Recreate primary, unique and foreign key constraints 
alter table WMOFFLINEVSONLINE
  add constraint PK_OFFLINE primary key (PID, MEMBERCARDNO)
  using index 
  tablespace DATA_SPC
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Create table
create table HY_WM_JFHZ
(
  CDLSEQNO NUMBER not null,
  CDLCID   VARCHAR2(20) not null,
  JF       NUMBER,
  ISTRANS  VARCHAR2(2) default 'N' not null,
  PID      VARCHAR2(20) not null
) ;
-- Create/Recreate primary, unique and foreign key constraints 
alter table HY_WM_JFHZ
  add constraint PK_WM_JFHZ primary key (CDLSEQNO, PID) ;

-- Create table
create table WMGZH
(
  CLIENT_ID     VARCHAR2(32),
  PID           VARCHAR2(20) not null,
  NAME          VARCHAR2(128),
  AVATARURL     VARCHAR2(256),
  ACCESS_TOKEN  VARCHAR2(36) not null,
  REFRESH_TOKEN VARCHAR2(36) not null,
  STOREID       NUMBER
) ;
-- Add comments to the table 
comment on table WMGZH
  is '微盟公众号';
-- Add comments to the columns 
comment on column WMGZH.CLIENT_ID
  is '应用证书ID';
comment on column WMGZH.PID
  is '公众号平台ID';
comment on column WMGZH.NAME
  is '公众号平台名称';
comment on column WMGZH.AVATARURL
  is '公众号平台头像地址';
comment on column WMGZH.ACCESS_TOKEN
  is '访问钥匙';
comment on column WMGZH.REFRESH_TOKEN
  is '刷新钥匙';
comment on column WMGZH.STOREID
  is '门店号';
-- Create/Recreate primary, unique and foreign key constraints 
alter table WMGZH
  add constraint WMGZH_PK primary key (PID);
 

CREATE TABLE DBUSRVIP.WMOPLOG
(
  ID         NUMBER                             NOT NULL,
  LOGTIME    DATE                               NOT NULL,
  LOGTYP     CHAR(1 BYTE)                       NOT NULL,
  OPER       CHAR(7 BYTE)                       NOT NULL,
  MODULE     CHAR(7 BYTE)                       NOT NULL,
  MSGDETAIL  VARCHAR2(200 BYTE)                 NOT NULL,
  BK1        CHAR(60 BYTE)
) ;

CREATE OR REPLACE PROCEDURE prc_log (
                            p_ID         IN VARCHAR,
                            --靠靠  1,靠? 靠
                            v_logtyp      IN VARCHAR,
                            --靠靠
                            v_oper        IN VARCHAR, 
                            --靠靠
                            v_module      IN VARCHAR,
                            --靠靠靠
                            v_msgdetail   IN VARCHAR)
   AS
   BEGIN
      INSERT INTO WMOPLOG (id, logtime,
                         logtyp,  oper, 
                         module, msgdetail)
         SELECT p_ID, SYSDATE, v_logtyp,
                v_oper,  v_module, v_msgdetail
           FROM DUAL;
 
   EXCEPTION
      WHEN OTHERS
      THEN 
         RETURN;
   END prc_log;
CREATE OR REPLACE PROCEDURE HY_WMMemberUPdat (
   V_PID         IN VARCHAR2,                                     --公众号平台ID
   V_cmobile   IN VARCHAR2                                            --手机号
                          )
AS
   V_storeID   VARCHAR (10);
BEGIN
   SELECT REPLACE (LPAD (storeid, 4), ' ', '0')
     INTO V_storeID
     FROM wmgzh
    WHERE pid = V_PID;

   UPDATE Custmember c
      SET (Cmname,
           cmbirthday,
           cmsex,
           cmaddr,
           cmadd1,
           cmadd2,
           cmadd3 ) =
             (SELECT m.name,
                     m.birthday,
                     m.sex,
                     m.address,
                     m.provinceName,
                     m.cityName,
                     m.districtName
                FROM WMMember m
               WHERE     pid = V_PID
                     AND c.cmmobile1 = m.memberCardNo
                     AND m.memberCardNo = V_cmobile
                     and c.cmmkt=V_storeID)
    WHERE EXISTS
             (SELECT 1
                FROM WMMember m
               WHERE     pid = V_PID
                     AND c.cmmobile1 = m.memberCardNo
                     AND m.memberCardNo = V_cmobile
                     and c.cmmkt=V_storeID);
    commit;
                         
 Exception
          When Others Then 
            Raise;
   end HY_WMMemberUPdat;

CREATE OR REPLACE Procedure HY_WMMemberAdd(   PID       In   Varchar2,      --公众号平台ID
                                        cname      In   Varchar2,           --姓名
                                       idno       In   Varchar2,            --身份证号
                                       birthday   In   Varchar2,            --生日时间戳
                                       sex        In   Varchar2,            --性别
                                       cadd1      In   Varchar2,            --XX省
                                       cadd2      In   Varchar2,            --XX市
                                       cadd3      In   Varchar2,            --XX区
                                       cadd4      In   Varchar2,            --XX详细地址
                                       cmobile    In   Varchar2,            --手机号
                                       allPoInts  in   number,                --会员积分
                                       Iscommit   In   Char Default 'Y',    --确认提交
                                       cardno     Out  Varchar2,             --输出卡号
                                       cardid     Out  Varchar2             --输出会员ID
                                       ) as
        Row_Card           Cardmain%Rowtype;
        Row_Cust           Customer%Rowtype;
        r_Cust             Customer%Rowtype;
        Row_Ymember        Custmember%Rowtype;
        Row_Member         Custmember%Rowtype;
        l_Havmember        Char(1);
        V_storeID        varchar(10);
        Cursor c_Cust(Custno Varchar2) Is
            Select * From Customer Where Cid = Custno;
        Cursor c_Member(Memid Varchar2) Is
            Select * From Custmember Where Cmmemid = Memid;
        Begin

             select  replace(lpad(storeid,4),' ','0')  into V_storeID from   wmgzh where pid=PID;

             Begin
              Select *
                Into Row_Ymember
                From Custmember
               Where Cmidtype = '1'   
                  And trim(cmmobile1) = cmobile
                  And Rownum = 1;
              l_Havmember := 'Y';
             Exception
              When No_Data_Found Then
                l_Havmember := 'N';
/*              When Others Then
                Raise_Application_Error(Errcode, '查找同证件号成员失败！');*/
             End;
            If l_Havmember ='Y' then
               Raise_Application_Error(-20001, '手机号[' || cmobile || ']已存在!');
            End If;
            Begin
              Select *
              Into Row_Card
              From Cardmain
              Where cdmno=(Select min(cdmno)
                            From Cardmain
                            Where  Cdmno between '37600000' and '37999999')
              For Update;
            Exception
              When Others Then
              Raise_Application_Error(-20001, '可用会员卡数量不足!');
            end;
            Sp_Autoseqno('52', 'N', Row_Cust.Cid);
            Open c_Cust(Row_Cust.Cid);
            Loop
              Fetch c_Cust
                Into r_Cust;
              Exit When c_Cust%Notfound Or c_Cust%Notfound Is Null;
              Sp_Autoseqno('52', 'N', Row_Cust.Cid);
            End Loop;
            Row_Cust.Ctype      := Row_Card.Cdmtype;
            Row_Cust.Cvipno     := Row_Card.Cdmno;
            Row_Cust.Cstatus    := 'Y';
            Row_Cust.Ccurjfye   := '0';
            Row_Cust.Chisjfye   := '0';
            Row_Cust.Ctotjfye   := '0';
            Row_Cust.Ccurxfje   := '0';
            Row_Cust.Chisxfje   := '0';
            Row_Cust.Ctotxfje   := '0';
            Row_Cust.Ccreator   := 'WMDOWN';
            Row_Cust.Cmaintor   := 'WMDOWN';
            Row_Cust.Ccreatdate := Trunc(Sysdate);
            Row_Cust.Cmaintdate := Trunc(Sysdate);
            Row_Cust.Cdate1     := Trunc(Sysdate);
            Insert Into Customer
            (Cid,Cvipno,Ctype,Cstatus,Ccurjfye,Chisjfye,Ctotjfye,Ccurxfje,Chisxfje,Ctotxfje,Ccreator,Cmaintor,Ccreatdate,Cmaintdate,Cdate1)
            Values
              ( Row_Cust.Cid,
                Row_Cust.Cvipno,
                Row_Cust.Ctype,
                Row_Cust.Cstatus,
                Row_Cust.Ccurjfye,
                Row_Cust.Chisjfye,
                Row_Cust.Ctotjfye,
                Row_Cust.Ccurxfje,
                Row_Cust.Chisxfje,
                Row_Cust.Ctotxfje,
                Row_Cust.Ccreator,
                Row_Cust.Cmaintor,
                Row_Cust.Ccreatdate,
                Row_Cust.Cmaintdate,
                Row_Cust.Cdate1);
            Insert Into Cardlog
                (Cdlseqno,
                 Cdltype,
                 Cdlmkt,
                 Cdlcno,
                 Cdlcid,
                 Cdlcmkt,
                 Cdlmcard,
                 Cdlflag,
                 Cdltrans,
                 Cdldate,
                 Cdloperid)
              Values
                (Seq_Cardlog.Nextval,
                 Row_Cust.Ctype,
                 V_storeID,
                 Row_Card.Cdmno,
                 Row_Cust.Cid,
                 V_storeID,
                 'Y',
                 Row_Card.Cdmflag,
                 '19',
                 Sysdate,
                 'WMDOWN');
          Sp_Autoseqno('C2', 'N', Row_Member.Cmmemid);
          Open c_Member(Row_Member.Cmmemid);
          Loop
            Fetch c_Member
              Into Row_Member;
            Exit When c_Member%Notfound Or c_Member%Notfound Is Null;
            Sp_Autoseqno('C2', 'N', Row_Member.Cmmemid);
          End Loop;
          Insert Into Custmember
          (Cmmemid,
           Cmcustid,
           Cmisowner,
           Cmrelation,
           Cmmaintor,
           Cmflag1,
           Cmjfxfxe,
           Cmname,
           Cmbirthday,
           Cmbirthtype,
           Cmsex,
           Cmaddr,
           Cmadd1,
           Cmadd2,
           Cmadd3,
           Cmadd4,
           Cmidtype,
           Cmidno,
           Cmlxtype1,
           Cmlxtype2,
           Cmlxtype3,
           Cmlxtype4,
           Cmlxtype5,
           Cmmobile1,
           Cmisemployee,
           Cmdkjf,
           Cmdhisjf,
           Cmmkt,
           Cmmaintdate,
           Cmkhdate,
           Cmsjdate )
          Values
          (Row_Cust.Cid,
           Row_Cust.Cid,
           Row_Card.Cdmmcard,
           '0',
           'WMDOWN',
           'Y',
           '0',
           cname,
           to_date(birthday,'YYYY-MM-DD'),
           '1',
           decode(sex,2,'F','M'),
           cadd1||cadd2||cadd3||cadd4,
           cadd1,
           cadd2,
           cadd3,
           cadd4,
           '1',
           idno,
           '0',
           '0',
           '0',
           '0',
           '0',
           cmobile,
           'N',
           '0',
           '0',
           V_storeID,
           Sysdate,
           Trunc(Sysdate),
           Trunc(Sysdate) );
        Insert Into Cardlog
          (Cdlseqno,
           Cdltype,
           Cdlmkt,
           Cdlcno,
           Cdlcid,
           Cdlcmkt,
           Cdlmcard,
           Cdlflag,
           Cdltrans,
           Cdldate,
           Cdloperid,
           Cdlmemo)
        Values
          (Seq_Cardlog.Nextval,
           Row_Cust.Ctype,
           V_storeID,
           Row_Card.Cdmno,
           Row_Cust.Cid,
           V_storeID,
           Row_Card.Cdmmcard,
           Row_Card.Cdmflag,
           '50',
           Sysdate,
           'WMDOWN',
           '成员ID' || Row_Cust.Cid);
           Select Seq_Cardseqno.Nextval Into Row_Card.Cdmseqno From Dual;
            Update Cardmain
               Set Cdmcid     = Row_Cust.Cid,
                 /*  Cdmmcard   = Row_Card.Cdmmcard,*/
                   Cdmstatus  = 'Y',
                   Cdmflag    = '04',
                   Cdmmindate = Trunc(Sysdate),
                   Cdmmaxdate = Add_Months(SYSDATE, 84) - 1,
                   Cdmdate1   = Trunc(Sysdate),
                   Cdmowner   = Row_Cust.Cid,
                   Cdmmode    = '8',
                   Cdmseqno   = Row_Card.Cdmseqno
                   /*Cdmflag1   = Row_Card.Cdmflag1*/
             Where Cdmno = Row_Card.Cdmno;
          Insert Into Cardlog
            (Cdlseqno,
             Cdltype,
             Cdlmkt,
             Cdlcno,
             Cdlcid,
             Cdlcmkt,
             Cdlmcard,
             Cdlflag,
             Cdltrans,
             Cdldate,
             Cdloperid,
             Cdlchr2)
          Values
            (Seq_Cardlog.Nextval,
             Row_Cust.Ctype,
             V_storeID,
             Row_Card.Cdmno,
             Row_Cust.Cid,
             V_storeID,
             Row_Card.Cdmmcard,
             '04',
             '05',
             Sysdate,
             'WMDOWN',
             '8');
             If Iscommit = 'Y' Then
             Commit;
             End If;
          cardno   := Row_Card.Cdmno;
          cardid   := Row_Cust.Cid;
       Exception
          When Others Then
            cardno   := '';
            cardid := '';
            If Iscommit = 'Y' Then
              Rollback;
            End If;
            Raise;
       end HY_WMMemberAdd;

/*End HY_Custsrv;*/


CREATE OR REPLACE PROCEDURE PRC_Wmmember_IMPORT (V_PID       IN     VARCHAR,
                                                 OUTSTATUS      OUT INTEGER)
AS
   --店铺号
   V_storeID         VARCHAR (10) :='0000';
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
   V_totjf           number;    --线下卡上积分                                                    
   V_Fl              number;    --是否产生负分
   
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
  -- DBMS_OUTPUT.PUT_LINE(V_PID);

   SELECT REPLACE (LPAD (storeid, 4), ' ', '0')
     INTO V_storeID
     FROM wmgzh
    WHERE pid = trim( V_PID);


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
                          
                 SELECT  ctotjfye  into V_totjf   FROM CUSTOMER   WHERE cid = V_CID;
                 V_Fl:=0;
                 if V_ADDORREDUCE='1'  and V_POSINTS>V_totjf then
                    V_Fl:=1;
                 end if;
                 
               IF V_GetFAIL > 0 and V_Fl<>1
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

