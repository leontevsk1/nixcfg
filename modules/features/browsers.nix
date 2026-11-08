{ ... }: {
  # Браузеры, общие для всех хостов.
  flake.nixosModules.browsers = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.chromium ];

    # Firefox: декларативная приватность (Enterprise Policies, применяются при каждом старте).
    # Философия: без урезания функционала — cookies НЕ чистятся, звонки/загрузки работают.
    # Ключи с точками — ОБЯЗАТЕЛЬНО в кавычках (иначе Nix строит вложенные attrsets).
    # Здесь только то, что должно быть одинаковым везде: приватность и прокси.
    # Расширения, профиль, UI и вкладки/группы настраивает сам браузер.
    programs.firefox = {
      enable = true;
      preferencesStatus = "user";
      preferences = {
        # --- Телеметрия и отправка данных ---
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.healthreport.uploadEnabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "browser.discovery.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;

        # --- Спонсорский контент и рекомендации ---
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.urlbar.quicksuggest.dataCollection.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

        # --- Преждевременные соединения (утечки keystrokes/URL) ---
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.search.suggest.enabled" = false;
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.predictor.enabled" = false;
        "network.http.speculative-parallel-limit" = 0;
        "network.connectivity-service.enabled" = false;
        "network.captive-portal-service.enabled" = false;
        "browser.region.update.enabled" = false;

        # --- SafeBrowsing: локальная защита остаётся, отправка URL/files в Google — нет ---
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.safebrowsing.downloads.remote.url" = "";
        "browser.safebrowsing.provider.google4.dataSharing.enabled" = false;
        "browser.safebrowsing.provider.google4.dataSharingURL" = "";
        "browser.safebrowsing.provider.google.dataSharing.enabled" = false;

        # --- Прокси: системный (gsettings org.gnome.system.proxy, см. proxy.nix) ---
        # type 5 = системные настройки: прокси есть, только пока в Throne включён
        # System Proxy. Хост/порт здесь НЕ задаём.
        "network.proxy.type" = 5;
        "network.proxy.socks_remote_dns" = true;

        # --- DoH в браузере выключен явно (резолв — через Throne/VPS) ---
        "network.trr.mode" = 0;
        "network.trr.uri" = "";

        # --- HTTPS-Only ---
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_send_http_background_request" = false;

        # --- OCSP off: запросы к CA палят browsing; отзыв через CRLite ---
        "security.OCSP.enabled" = 0;
        "security.OCSP.require" = false;

        # --- WebRTC: звонки работают, локальные IP не светятся ---
        "media.peerconnection.ice.no_host" = true;
        "media.peerconnection.ice.default_address_only" = true;

        # --- Прочие утечки ---
        "geo.enabled" = false;
        "dom.battery.enabled" = false;
        "browser.uitour.enabled" = false;
        "browser.uitour.url" = "";
        "browser.sessionstore.privacy_level" = 2;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.webexposed" = true;
        "network.auth.subresource-http-auth-allow" = 1;
        "extensions.pocket.enabled" = false;

        # --- ETP Strict (трекеры, браузерная антифингерпринт-защита) ---
        "browser.contentblocking.category" = "strict";

        # --- Вкладки ---
        # Группы включены явно; «умные» группы — локальная ML-модель, не нужна.
        "browser.tabs.groups.enabled" = true;
        "browser.tabs.groups.smart.enabled" = false;
        "browser.tabs.groups.smart.userEnabled" = false;
      };
    };
  };
}
