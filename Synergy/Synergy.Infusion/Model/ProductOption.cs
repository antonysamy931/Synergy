using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Infusion.Model
{
    public class ProductOption
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("label")]
        public string Label { get; set; }

        //If this option is required for purchase.
        [JsonProperty("required")]
        public bool Required { get; set; }

        //The type of option. Valid values are Variable or FixedList
        [JsonProperty("type")]
        public string Type { get; set; }

        [JsonProperty("min_chars")]
        public int MinChars { get; set; }

        [JsonProperty("max_chars")]
        public int MaxChars { get; set; }

        [JsonProperty("can_start_with_character")]
        public bool CanStartWithCharacter { get; set; }

        [JsonProperty("can_start_with_number")]
        public bool CanStartWithNumber { get; set; }

        [JsonProperty("can_contain_character")]
        public bool CanContainCharacter { get; set; }

        [JsonProperty("can_contain_number")]
        public bool CanContainNumber { get; set; }

        [JsonProperty("can_end_with_character")]
        public bool CanEndWithCharacter { get; set; }

        [JsonProperty("can_end_with_number")]
        public bool CanEndWithNumber { get; set; }

        [JsonProperty("allow_spaces")]
        public bool AllowSpaces { get; set; }

        [JsonProperty("text_message")]
        public string TextMessage { get; set; }

        [JsonProperty("display_index")]
        public int DisplayIndex { get; set; }

        [JsonProperty("values")]
        public List<OptionValue> Values { get; set; }
    }
}
