using Synergy.Common.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Enforcer
{
    public class SynergyEnforcer : EnforcerBehavior
    {
        public override bool Validate(string operationName, object[] inputs)
        {
            SynergyRequest request = inputs[0] as SynergyRequest;
            if (request == null || request.UserId == 0)
                throw new Exception("Unauthorized synergy user request.");
            return true;
        }
    }
}
