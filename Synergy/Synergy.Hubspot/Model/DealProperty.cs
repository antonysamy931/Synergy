﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Hubspot.Model
{
    public class DealProperty
    {
        public string value { get; set; }
        public long timestamp { get; set; }
        public string source { get; set; }
        public object sourceId { get; set; }
        public DealVersion[] versions { get; set; }
    }
}