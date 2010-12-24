--
-- Table structure for table messages
--
CREATE TABLE messages (
  id int(11) NOT NULL auto_increment,
  context varchar(80) NOT NULL default '',
  mailbox varchar(80) NOT NULL default '0',
  folder tinyint(2) NOT NULL default '1',
  caller_id_number varchar(40) NOT NULL default '',
  caller_id_name varchar(80) NOT NULL default '',
  timestamp bigint(11) NOT NULL default '0',
  duration int(11) NOT NULL default '0',
  deleted tinyint(1) NOT NULL default '0',
  recording text,
  PRIMARY KEY  (id),
  KEY mailbox (mailbox),
  KEY deleted (deleted)
);

--
-- Table structure for table voicemail
--
CREATE TABLE voicemail (
  uniqueid int(11) NOT NULL auto_increment,
  customer_id char(80) NOT NULL default '',
  context char(80) NOT NULL default 'default',
  mailbox char(80) NOT NULL default '',
  password char(80) NOT NULL default '',
  fullname char(80) NOT NULL default '',
  email char(255) NOT NULL default '',
  pager char(80) NOT NULL default '',
  attach char(3) NOT NULL default 'yes',
  attachfmt char(10) NOT NULL default 'wav49',
  serveremail char(80) NOT NULL default '',
  language char(20) NOT NULL default 'en',
  tz char(30) NOT NULL default 'central',
  deletevoicemail char(3) NOT NULL default 'yes',
  nextaftercmd char(4) NOT NULL default 'yes',
  hidefromdir char(4) NOT NULL default 'yes',
  saycid char(3) NOT NULL default 'no',
  sendvoicemail char(3) NOT NULL default 'no',
  review char(3) NOT NULL default 'no',
  tempgreetwarn char(3) NOT NULL default 'no',
  operator char(3) NOT NULL default 'no',
  envelope char(3) NOT NULL default 'no',
  sayduration char(3) NOT NULL default 'no',
  saydurationm int(3) NOT NULL default '1',
  forcename char(3) NOT NULL default 'no',
  forcegreetings char(3) NOT NULL default 'no',
  callback char(80) NOT NULL default '',
  dialout char(80) NOT NULL default '',
  exitcontext char(80) NOT NULL default '',
  maxmsg int(5) NOT NULL default '100',
  volgain decimal(5,2) NOT NULL default '0.00',
  imapuser varchar(80) NOT NULL default '',
  imappassword varchar(80) NOT NULL default '',
  stamp timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (uniqueid),
  KEY mailbox_context (mailbox,context)
);

