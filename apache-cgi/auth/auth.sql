GRANT SELECT,INSERT,UPDATE,DELETE ON ht.pt_exclusivity_ng TO `mdp-lib`;

--- inserts for users with elevated access

--- inserts/updates for ht_institutions
REPLACE INTO ht.ht_institutions (inst_id, name, domain, us, enabled, entityID, allowed_affiliations) 
  VALUES ('umich','University of Michigan','umich.edu','1','1','https://shibboleth.umich.edu/idp/shibboleth','^(member|alum|faculty|staff|student|employee)@umich.edu');

REPLACE INTO ht.ht_institutions (inst_id, name, domain, us, enabled, entityID, allowed_affiliations) 
  VALUES ('hathitrust','HathiTrust','hathitrust.org','1','1','https://idp.hathitrust.org/entity','^(member|alum|faculty|staff|student|employee)@hathitrust.org');

REPLACE INTO ht.ht_institutions (inst_id, name, domain, us, enabled, entityID, allowed_affiliations) 
  VALUES ('nfb','National Federation of the Blind','nfb.org','1','1','pumex-idp','^(member)@nfb.org');
