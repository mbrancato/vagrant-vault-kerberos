﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

namespace FancyApp.Pages
{
  public class IndexModel : PageModel
  {
    public string RequestMsg { get; set; }
    public string ResponseMsg { get; set; }
    public string ResponseContent { get; set; }

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
        PreAuthenticate = true,
      };

      using (var client = new HttpClient(handler))
      {
        var req = new HttpRequestMessage(HttpMethod.Post, host);

        RequestMsg = req.ToString();
        using (HttpResponseMessage response = client.SendAsync(req).Result)
        {
          ResponseMsg = response.ToString();
          using (HttpContent content = response.Content)
          {
            ResponseContent = JObject.Parse(content.ReadAsStringAsync().Result).ToString();
          }
        }
      }
    }
  }
}
