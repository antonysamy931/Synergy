using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class ContactProperties
    {
        [JsonProperty("website")]
        public ResponseProperty Website { get; set; }
        [JsonProperty("city")]
        public ResponseProperty City { get; set; }
        [JsonProperty("firstname")]
        public ResponseProperty FirstName { get; set; }
        [JsonProperty("zip")]
        public ResponseProperty ZipCode { get; set; }
        [JsonProperty("lastname")]
        public ResponseProperty LastName { get; set; }
        [JsonProperty("company")]
        public ResponseProperty Company { get; set; }
        [JsonProperty("phone")]
        public ResponseProperty Phone { get; set; }
        [JsonProperty("state")]
        public ResponseProperty State { get; set; }
        [JsonProperty("address")]
        public ResponseProperty Address { get; set; }
        [JsonProperty("email")]
        public ResponseProperty Email { get; set; }
        [JsonProperty("deletedchangedtimestamp")]
        public ResponseProperty DeletedChangedTimeStamp { get; set; }
        public ResponseProperty hs_analytics_last_url { get; set; }
        public ResponseProperty lead_source { get; set; }
        public ResponseProperty num_unique_conversion_events { get; set; }
        public ResponseProperty hs_analytics_revenue { get; set; }
        public ResponseProperty createdate { get; set; }
        public ResponseProperty hs_analytics_first_referrer { get; set; }
        public ResponseProperty hs_email_optout { get; set; }
        public ResponseProperty hs_predictivecontactscore { get; set; }
        public ResponseProperty annualrevenue { get; set; }
        public ResponseProperty hs_analytics_num_page_views { get; set; }
        public ResponseProperty fortune_rank { get; set; }
        public ResponseProperty hs_predictivecontactscorebucket { get; set; }
        public ResponseProperty hubspotscore { get; set; }
        public ResponseProperty linkedinconnections { get; set; }
        public ResponseProperty hs_lifecyclestage_subscriber_date { get; set; }
        public ResponseProperty hs_analytics_average_page_views { get; set; }
        public ResponseProperty twitterhandle { get; set; }
        public ResponseProperty num_conversion_events { get; set; }
        public ResponseProperty currentlyinworkflow { get; set; }
        public ResponseProperty hs_analytics_num_event_completions { get; set; }
        public ResponseProperty followercount { get; set; }
        public ResponseProperty hs_email_optout_2849 { get; set; }
        public ResponseProperty associatedcompanyid { get; set; }
        public ResponseProperty hs_email_optout_354586 { get; set; }
        public ResponseProperty hs_social_num_broadcast_clicks { get; set; }
        public ResponseProperty hs_analytics_last_timestamp { get; set; }
        public ResponseProperty hs_analytics_num_visits { get; set; }
        public ResponseProperty twitterbio { get; set; }
        public ResponseProperty hs_social_linkedin_clicks { get; set; }
        public ResponseProperty hs_analytics_last_visit_timestamp { get; set; }
        public ResponseProperty hs_social_last_engagement { get; set; }
        public ResponseProperty hs_twitterid { get; set; }
        public ResponseProperty associatedcompanylastupdated { get; set; }
        public ResponseProperty hs_analytics_source { get; set; }
        public ResponseProperty linkedinbio { get; set; }
        public ResponseProperty hs_analytics_first_url { get; set; }
        public ResponseProperty hs_analytics_first_visit_timestamp { get; set; }
        public ResponseProperty hs_analytics_first_timestamp { get; set; }
        public ResponseProperty lastmodifieddate { get; set; }
        public ResponseProperty photo { get; set; }
        public ResponseProperty hs_social_google_plus_clicks { get; set; }
        public ResponseProperty hs_analytics_last_referrer { get; set; }
        public ResponseProperty kloutscoregeneral { get; set; }
        public ResponseProperty hs_email_optout_230318 { get; set; }
        public ResponseProperty hs_social_facebook_clicks { get; set; }
        public ResponseProperty twitterprofilephoto { get; set; }
        public ResponseProperty hs_analytics_source_data_2 { get; set; }
        public ResponseProperty hs_social_twitter_clicks { get; set; }
        public ResponseProperty hs_analytics_source_data_1 { get; set; }
        public ResponseProperty lifecyclestage { get; set; }
    }
}
