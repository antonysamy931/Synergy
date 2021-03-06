﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Synergy.Common;
using System.IO;
using Synergy.Common.Utilities;

namespace Synergy.Common.Request
{
    public class WebClient
    {
        public HttpWebResponse Post(IContentType message, string authToken, string contentType, bool returnErrorResponses = false, IDictionary<string, string> headers = null, bool SetExpect100Continue = true)
        {
            HttpWebRequest POSTRequest = (HttpWebRequest)WebRequest.Create(message.Url);
            //Method type
            POSTRequest.Method = RequestTypes.POST.ToString();

            if (!string.IsNullOrEmpty(authToken))
            {
                POSTRequest.Headers.Add("Authorization", authToken);
            }

            if (null != headers)
            {
                foreach (var header in headers)
                {
                    POSTRequest.Headers.Add(header.Key, header.Value);
                }
            }
            POSTRequest.ContentType = contentType;
            POSTRequest.Accept = EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON);
            POSTRequest.MediaType = contentType;
            POSTRequest.KeepAlive = false;
            POSTRequest.ServicePoint.Expect100Continue = SetExpect100Continue;
            
            if (message.Content != null && message.Content.Length > 0)
            {
                //Content length of message body
                POSTRequest.ContentLength = message.Content.Length;

                // Get the request stream
                Stream POSTstream = POSTRequest.GetRequestStream();
                // Write the data bytes in the request stream
                POSTstream.Write(message.Content, 0, message.Content.Length);
            }

            try
            {
                // Return the response.
                return POSTRequest.GetResponse() as HttpWebResponse;
            }
            catch (WebException e)
            {
                // Interestingly HttpWebRequest.GetResponse() will raise an exception if the response status is not 200, but
                // if it is a bad request (400), for example, the content of the response may indicate what is wrong with the
                // request. Therefore, we allow the caller to override this default behavior.
                if (returnErrorResponses)
                {
                    return e.Response as HttpWebResponse;
                }
                else
                {
                    throw;
                }
            }
        }

        public HttpWebResponse Post(string message, string url, string authToken, string contentType, bool returnErrorResponses = false, IDictionary<string, string> headers = null, bool SetExpect100Continue = true)
        {
            HttpWebRequest POSTRequest = (HttpWebRequest)WebRequest.Create(url);
            //Method type
            POSTRequest.Method = RequestTypes.POST.ToString();

            if (!string.IsNullOrEmpty(authToken))
            {
                POSTRequest.Headers.Add("Authorization", authToken);
            }

            if (null != headers)
            {
                foreach (var header in headers)
                {
                    POSTRequest.Headers.Add(header.Key, header.Value);
                }
            }
            POSTRequest.ContentType = contentType;
            POSTRequest.Accept = EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON);
            POSTRequest.MediaType = contentType;
            POSTRequest.KeepAlive = false;
            POSTRequest.ServicePoint.Expect100Continue = SetExpect100Continue;

            if (!string.IsNullOrEmpty(message) && message.Length > 0)
            {
                //Content length of message body
                POSTRequest.ContentLength = message.Length;

                using (Stream webStream = POSTRequest.GetRequestStream())
                using (StreamWriter requestWriter = new StreamWriter(webStream, System.Text.Encoding.ASCII))
                {
                    requestWriter.Write(message);
                }
            }

            try
            {
                // Return the response.
                return POSTRequest.GetResponse() as HttpWebResponse;
            }
            catch (WebException e)
            {
                // Interestingly HttpWebRequest.GetResponse() will raise an exception if the response status is not 200, but
                // if it is a bad request (400), for example, the content of the response may indicate what is wrong with the
                // request. Therefore, we allow the caller to override this default behavior.
                if (returnErrorResponses)
                {
                    return e.Response as HttpWebResponse;
                }
                else
                {
                    throw;
                }
            }
        }

        public HttpWebResponse Get(IContentType message, string contentType, string authToken = "", bool returnErrorResponses = false, IDictionary<string, string> headers = null, bool SetExpect100Continue = true)
        {
            HttpWebRequest GETRequest = (HttpWebRequest)WebRequest.Create(message.Url);
            //Method type
            GETRequest.Method = RequestTypes.GET.ToString();
            try
            {
                if (!string.IsNullOrEmpty(authToken))
                {
                    GETRequest.Headers.Add("Authorization", authToken);
                }
                // Return the response.
                return GETRequest.GetResponse() as HttpWebResponse;
            }
            catch (WebException e)
            {
                // Interestingly HttpWebRequest.GetResponse() will raise an exception if the response status is not 200, but
                // if it is a bad request (400), for example, the content of the response may indicate what is wrong with the
                // request. Therefore, we allow the caller to override this default behavior.
                if (returnErrorResponses)
                {
                    return e.Response as HttpWebResponse;
                }
                else
                {
                    throw;
                }
            }
        }

        public HttpWebResponse Get(string url, string contentType, string authToken = "", bool returnErrorResponses = false, IDictionary<string, string> headers = null, bool SetExpect100Continue = true)
        {
            HttpWebRequest GETRequest = (HttpWebRequest)WebRequest.Create(url);
            //Method type
            GETRequest.Method = RequestTypes.GET.ToString();
            try
            {
                if (!string.IsNullOrEmpty(contentType))
                {
                    GETRequest.ContentType = contentType;
                    GETRequest.Accept = EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON); 
                }

                if (!string.IsNullOrEmpty(authToken))
                {
                    GETRequest.Headers.Add("Authorization", authToken);
                }
                // Return the response.
                return GETRequest.GetResponse() as HttpWebResponse;
            }
            catch (WebException e)
            {
                // Interestingly HttpWebRequest.GetResponse() will raise an exception if the response status is not 200, but
                // if it is a bad request (400), for example, the content of the response may indicate what is wrong with the
                // request. Therefore, we allow the caller to override this default behavior.
                if (returnErrorResponses)
                {
                    return e.Response as HttpWebResponse;
                }
                else
                {
                    throw;
                }
            }
        }

        public HttpWebResponse Put(IContentType message, string authToken, string contentType, bool returnErrorResponses = false, IDictionary<string, string> headers = null, bool SetExpect100Continue = true)
        {
            HttpWebRequest PUTRequest = (HttpWebRequest)WebRequest.Create(message.Url);
            //Method type
            PUTRequest.Method = RequestTypes.PUT.ToString();

            if (!string.IsNullOrEmpty(authToken))
            {
                PUTRequest.Headers.Add("Authorization", authToken);
            }

            if (null != headers)
            {
                foreach (var header in headers)
                {
                    PUTRequest.Headers.Add(header.Key, header.Value);
                }
            }
            PUTRequest.ContentType = contentType;
            PUTRequest.Accept = EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON);
            PUTRequest.MediaType = contentType;
            PUTRequest.KeepAlive = false;
            PUTRequest.ServicePoint.Expect100Continue = SetExpect100Continue;

            if (message.Content != null && message.Content.Length > 0)
            {
                //Content length of message body
                PUTRequest.ContentLength = message.Content.Length;

                // Get the request stream
                Stream POSTstream = PUTRequest.GetRequestStream();
                // Write the data bytes in the request stream
                POSTstream.Write(message.Content, 0, message.Content.Length);
            }

            try
            {
                // Return the response.
                return PUTRequest.GetResponse() as HttpWebResponse;
            }
            catch (WebException e)
            {
                // Interestingly HttpWebRequest.GetResponse() will raise an exception if the response status is not 200, but
                // if it is a bad request (400), for example, the content of the response may indicate what is wrong with the
                // request. Therefore, we allow the caller to override this default behavior.
                if (returnErrorResponses)
                {
                    return e.Response as HttpWebResponse;
                }
                else
                {
                    throw;
                }
            }
        }

        public HttpWebResponse Put(string message, string url, string authToken, string contentType, bool returnErrorResponses = false, IDictionary<string, string> headers = null, bool SetExpect100Continue = true)
        {
            HttpWebRequest PUTRequest = (HttpWebRequest)WebRequest.Create(url);
            //Method type
            PUTRequest.Method = RequestTypes.PUT.ToString();

            if (!string.IsNullOrEmpty(authToken))
            {
                PUTRequest.Headers.Add("Authorization", authToken);
            }

            if (null != headers)
            {
                foreach (var header in headers)
                {
                    PUTRequest.Headers.Add(header.Key, header.Value);
                }
            }
            PUTRequest.ContentType = contentType;
            PUTRequest.Accept = EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON);
            PUTRequest.MediaType = contentType;
            PUTRequest.KeepAlive = false;
            PUTRequest.ServicePoint.Expect100Continue = SetExpect100Continue;

            if (!string.IsNullOrEmpty(message) && message.Length > 0)
            {
                //Content length of message body
                PUTRequest.ContentLength = message.Length;

                using (Stream webStream = PUTRequest.GetRequestStream())
                using (StreamWriter requestWriter = new StreamWriter(webStream, System.Text.Encoding.ASCII))
                {
                    requestWriter.Write(message);
                }
            }

            try
            {
                // Return the response.
                return PUTRequest.GetResponse() as HttpWebResponse;
            }
            catch (WebException e)
            {
                // Interestingly HttpWebRequest.GetResponse() will raise an exception if the response status is not 200, but
                // if it is a bad request (400), for example, the content of the response may indicate what is wrong with the
                // request. Therefore, we allow the caller to override this default behavior.
                if (returnErrorResponses)
                {
                    return e.Response as HttpWebResponse;
                }
                else
                {
                    throw;
                }
            }
        }

        public HttpWebResponse Delete(string requestUrl, string contentType, string authToken = "", bool returnErrorResponses = false)
        {
            HttpWebRequest DELETERequest = (HttpWebRequest)WebRequest.Create(requestUrl);
            //Method type
            DELETERequest.Method = RequestTypes.DELETE.ToString();
            DELETERequest.ContentType = contentType;
            DELETERequest.Accept = EnumUtilities.GetDescriptionFromEnumValue(ContentTypes.JSON);
            try
            {
                if (!string.IsNullOrEmpty(authToken))
                {
                    DELETERequest.Headers.Add("Authorization", authToken);
                }
                // Return the response.
                return DELETERequest.GetResponse() as HttpWebResponse;
            }
            catch (WebException e)
            {
                // Interestingly HttpWebRequest.GetResponse() will raise an exception if the response status is not 200, but
                // if it is a bad request (400), for example, the content of the response may indicate what is wrong with the
                // request. Therefore, we allow the caller to override this default behavior.
                if (returnErrorResponses)
                {
                    return e.Response as HttpWebResponse;
                }
                else
                {
                    throw;
                }
            }
        }
    }
}
