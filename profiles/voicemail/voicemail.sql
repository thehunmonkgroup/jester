--
-- Mailbox settings.
--
CREATE TABLE mailbox (
  domain char(80) NOT NULL DEFAULT '',
  mailbox char(80) NOT NULL DEFAULT '',
  `password` char(80) NOT NULL DEFAULT '',
  customer_id char(80) NOT NULL DEFAULT '',
  full_name char(80) NOT NULL DEFAULT '',
  mailbox_setup_complete char(3) NOT NULL DEFAULT 'no',
  mailbox_provisioned char(3) NOT NULL DEFAULT 'no',
  message_lifetime int(11) NOT NULL DEFAULT '-1',
  max_messages int(5) NOT NULL DEFAULT '100',
  default_language char(20) NOT NULL DEFAULT 'en',
  default_timezone char(50) NOT NULL DEFAULT 'Etc/UTC',
  email char(255) NOT NULL DEFAULT '',
  email_template char(255) NOT NULL DEFAULT '',
  email_messages char(20) NOT NULL DEFAULT 'no',
  play_caller_id char(3) NOT NULL DEFAULT 'no',
  play_envelope char(3) NOT NULL DEFAULT 'no',
  review_messages char(3) NOT NULL DEFAULT 'yes',
  next_after_command char(3) NOT NULL DEFAULT 'yes',
  directory_entry char(3) NOT NULL DEFAULT 'yes',
  temp_greeting_warn char(3) NOT NULL DEFAULT 'no',
  force_name char(3) NOT NULL DEFAULT 'no',
  force_greetings char(3) NOT NULL DEFAULT 'no',
  operator_extension char(80) NOT NULL DEFAULT '',
  callback_extension char(80) NOT NULL DEFAULT '',
  outdial_extension char(80) NOT NULL DEFAULT '',
  exit_extension char(80) NOT NULL DEFAULT '',
  stamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (domain,mailbox)
) DEFAULT CHARSET=utf8;

--
-- Voicemail messages.
--
CREATE TABLE message (
  id int(11) NOT NULL auto_increment,
  domain varchar(80) NOT NULL default '',
  mailbox varchar(80) NOT NULL default '0',
  folder tinyint(2) NOT NULL default '1',
  caller_id_number varchar(40) NOT NULL default '',
  caller_id_name varchar(80) NOT NULL default '',
  caller_domain varchar(80) NOT NULL default '',
  timestamp bigint(11) NOT NULL default '0',
  duration int(11) NOT NULL default '0',
  deleted tinyint(1) NOT NULL default '0',
  recording text,
  PRIMARY KEY (id),
  KEY domain_mailbox (domain, mailbox),
  KEY deleted (deleted)
);

--
-- Voicemail message groups.
--
CREATE TABLE message_group (
  group_name varchar(30) NOT NULL default '',
  domain varchar(255) NOT NULL default '',
  mailbox varchar(255) NOT NULL default '',
  PRIMARY KEY  (group_name, domain, mailbox)
);

