using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;

namespace FancyApp.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        public void OnGet()
        {

          var host = "http://vault.domain.local:8200/v1/auth/kerberos/domain.local/login";
          var handler = new HttpClientHandler
          {
              UseDefaultCredentials = true,
              AllowAutoRedirect = true,
          };
          
          using (var client = new HttpClient())
          {
              var req = new HttpRequestMessage(HttpMethod.Post, host);
              req.Credentials      = System.Net.CredentialCache.DefaultNetworkCredentials;

              var res = client.SendAsync(req);
              var responseResult = res.Result;
              RequestMsg = req.ToString();
              ResponseMsg = res.Result.ToString();
          }

        }
    }
}
