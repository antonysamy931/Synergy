using Synergy.Common.Model;
using Synergy.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;
using System.Text;
using System.Threading.Tasks;

namespace Synergy.Common.Enforcer
{
    public abstract class EnforcerBehavior : Attribute, IParameterInspector, IOperationBehavior
    {
        private static int RecordId { get; set; }

        public void AfterCall(string operationName, object[] outputs, object returnValue, object correlationState)
        {
            SynergyResponse response = returnValue as SynergyResponse;
            if (RecordId > 0 && response != null)
            {
                using (var context = new SynergyDbContext())
                {
                    var apiHistory = context.Synergy_ApiHistory.Where(x => x.Id == RecordId && x.IsActive).FirstOrDefault();
                    if (apiHistory != null)
                    {
                        apiHistory.Status = response.Status.ToString();
                        apiHistory.Message = response.Message;
                    }
                    context.SaveChanges();
                }
            }
        }

        public object BeforeCall(string operationName, object[] inputs)
        {
            SynergyRequest request = inputs[0] as SynergyRequest;
            using (var context = new SynergyDbContext())
            {
                var Api = context.Synergy_API.Where(x => x.Api.ToLower() == request.Api.ToString().ToLower()).FirstOrDefault();
                if (Api != null)
                {
                    LogApi(context, Api.Id, request);
                }
                else
                {
                    Synergy_Api api = new Synergy_Api()
                    {
                        Api = request.Api.ToString(),
                        IsActive = true
                    };
                    context.Synergy_API.Add(api);
                    context.SaveChanges();
                    LogApi(context, api.Id, request);
                }
            }
            return null;
        }

        public virtual void Validate(OperationDescription operationDescription)
        {
        }

        public virtual void ApplyDispatchBehavior(OperationDescription operationDescription, DispatchOperation dispatchOperation)
        {
            dispatchOperation.ParameterInspectors.Add(this);
        }

        public virtual void ApplyClientBehavior(OperationDescription operationDescription, ClientOperation clientOperation)
        {
        }

        public virtual void AddBindingParameters(OperationDescription operationDescription, BindingParameterCollection bindingParameters)
        {
        }

        public abstract bool Validate(string operationName, object[] inputs);

        private void LogApi(SynergyDbContext context, int apiId, SynergyRequest request)
        {
            var ApiLog = context.Synergy_ApiRequestLogs.Where(x => x.UserId == request.UserId
                && x.ApiId == apiId && x.IsActive).FirstOrDefault();
            if (ApiLog != null)
            {
                ApiLog.Requests = ApiLog.Requests + 1;
                context.SaveChanges();
                LogApiHistory(context, ApiLog.Id, request);
            }
            else
            {
                Synergy_ApiRequestLog LogApi = new Synergy_ApiRequestLog()
                {
                    ApiId = apiId,
                    IsActive = true,
                    Requests = 1,
                    UserId = request.UserId
                };
                context.Synergy_ApiRequestLogs.Add(LogApi);
                context.SaveChanges();
                LogApiHistory(context, LogApi.Id, request);
            }
        }

        private void LogApiHistory(SynergyDbContext context, int logId, SynergyRequest request)
        {
            Synergy_ApiHistory history = new Synergy_ApiHistory()
            {
                IsActive = true,
                LogId = logId,
                Request = request.Request,
                RequestDateTime = DateTime.UtcNow
            };
            context.Synergy_ApiHistory.Add(history);
            context.SaveChanges();
            RecordId = history.Id;
        }
        
    }
}
