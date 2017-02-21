using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot
{
    public enum Scope
    {        
        contacts, //Contacts, Companies, and Deals, along with the associated property APIs, Engagements API, Owners API	Marketing and CRM        
        content, //All COS APIs, Calendar API, Email and Email Events APIs	Marketing
        reports, //Keywords API	Marketing
        social,	//Social Media API	Marketing
        automation, //Workflows API	Marketing
        timeline, //Timelines API	Marketing and CRM
        forms, //Forms API	Marketing
        files, //File Manager API	Marketing and CRM
        hubdb, //HubDB API	Marketing with Website add on
        [Description("transactional-email")]
        TransactionalEmail //Transactional Email API	Marketing with Transactional Email add on
    }
}
