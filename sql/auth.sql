--- inserts for users with elevated access
REPLACE INTO ht.ht_users (userid, displayname, email, usertype, role, access, expires, iprestrict, identity_provider, inst_id) VALUES
('totaluser@hathitrust.org','HathiTrust Totaluser','totaluser@hathitrust.org','staff','staffdeveloper','total',ADD_MONTHS(CURRENT_TIMESTAMP, 60),'^.*$','https://idp.hathitrust.org/entity','hathitrust');

REPLACE INTO ht.ht_users (userid, displayname, email, usertype, role, access, expires, iprestrict, identity_provider, inst_id) VALUES
('ssdproxy@hathitrust.org','HathiTrust Ssdproxy','ssdproxy@hathitrust.org','external','ssdproxy','normal',ADD_MONTHS(CURRENT_TIMESTAMP, 60),'^.*$','https://idp.hathitrust.org/entity','hathitrust');

REPLACE INTO ht.ht_users (userid, displayname, email, usertype, role, access, expires, iprestrict, identity_provider, inst_id) VALUES
('ssduser@hathitrust.org','HathiTrust Ssduser','ssduser@hathitrust.org','student','ssd','normal',ADD_MONTHS(CURRENT_TIMESTAMP, 60),'^.*$','https://idp.hathitrust.org/entity','hathitrust');

--- inserts/updates for ht_institutions
REPLACE INTO ht.ht_institutions (inst_id, name, domain, us, enabled, entityID, allowed_affiliations) 
  VALUES ('umich','University of Michigan','umich.edu','1','1','https://shibboleth.umich.edu/idp/shibboleth','^(member|alum|faculty|staff|student|employee)@umich.edu');

REPLACE INTO ht.ht_institutions (inst_id, name, domain, us, enabled, entityID, allowed_affiliations) 
  VALUES ('hathitrust','HathiTrust','hathitrust.org','1','1','https://idp.hathitrust.org/entity','^(member|alum|faculty|staff|student|employee)@hathitrust.org');

REPLACE INTO ht.ht_institutions (inst_id, name, domain, us, enabled, entityID, allowed_affiliations) 
  VALUES ('nfb','National Federation of the Blind','nfb.org','1','1','pumex-idp','^(member)@nfb.org');

REPLACE INTO ht.ht_institutions (inst_id, name, domain, us, enabled, entityID, allowed_affiliations, emergency_status)  VALUES ('etas','ETAS Example Inst','etas.example','1','1','https://idp.etas.example','^(member)@etas.example','^(member)@etas.example');
