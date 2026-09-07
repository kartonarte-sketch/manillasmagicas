'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "0a177490c83ba1bbdb8128ce38c344c6",
".git/config": "49e04816adc03baa6df5b19fdb9af65f",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "31378859ce90b32cdeea1735304d7649",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "e0b5b08e209fa15f48d796e8976bc42b",
".git/hooks/fsmonitor-watchman.sample": "5c90c1740b0cacecb469934e16fe8cb6",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "5a634e2aa31dce327b3626d4ac4bdd62",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "06635b5c055dac6f751377574edd0c92",
".git/logs/refs/heads/gh-pages": "e15b590f8ab67421510d3d74bcea2b72",
".git/logs/refs/remotes/origin/gh-pages": "42d7912bf3d1a934809af25504203d69",
".git/objects/02/ad7f4c2463736480dd0f69cbf6666904dd18e8": "3027f2f6176341faaf0ee77506711687",
".git/objects/03/eaddffb9c0e55fb7b5f9b378d9134d8d75dd37": "87850ce0a3dd72f458581004b58ac0d6",
".git/objects/07/74c17c0fa7a7e87e24a6935830998d92b52c75": "cd62ee54b7ceea7b2a7804e69b1d9134",
".git/objects/0d/4c4e4f0421aa39e4401514bc68d09656c8fff2": "60766258b6da7b703c85f4023e8e1113",
".git/objects/11/3df633b3234c9e35b12b9eddcea082bc3a5836": "17e620d17a984012ac4cc6cb58fd8970",
".git/objects/13/2f4d8cdefcd84aec95a231011825d94bdede3d": "7e09b44eedcbd829e8b9b31271c7aa56",
".git/objects/16/5ce0ddf03a820a38f48cba9aa0c9df9b6e6b79": "71df17c95c3124eada62b59e7dabda78",
".git/objects/1a/562c2313ebf10f904db2e28def2b4783790830": "27597d096b441c32f43efc17b1a7b16c",
".git/objects/1a/5bf28cb99a88fddeb685274877d1937df7b700": "278f9fa6f6432105156f31bdfec7a3c7",
".git/objects/1b/7dfc6e7aeebd91b25363411ab0d35b27927d42": "f8e2c866255a39bf30b1efea40cead22",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/1f/98ec68e71a7841839911721952c6b5c9eb9ed3": "7b6c37301e33dc0be77c8c128b718be9",
".git/objects/20/1afe538261bd7f9a38bed0524669398070d046": "82a4d6c731c1d8cdc48bce3ab3c11172",
".git/objects/20/710f2483004eb062a396762acc10f492b78012": "42d1261375ab4ddb8b1b32e908d31c47",
".git/objects/25/8b3eee70f98b2ece403869d9fe41ff8d32b7e1": "05e38b9242f2ece7b4208c191bc7b258",
".git/objects/2c/4ddcf9b5c42fc9b0e4dfbf868b32eb446b4953": "5933d58e0d4aa15ad6f2b1b713885eef",
".git/objects/2c/d97aa252206b10ecfe6b949ace3e42b592e28b": "8dc9d316fa62f2751444386c00a3cd87",
".git/objects/2c/efd468dd6dae76e9426ab5cd74fc0c0fed53a1": "370a62d0328696140448e6a054feab36",
".git/objects/37/ce3f0d1e310a6b9f5ce8c888f0f3f438212b07": "57821cbbbf19896c0b499854f33558e7",
".git/objects/3d/b31523b5b0346ab2e51ad22ae39ed902753f6c": "50a93187d7605d0da7ab6221ab2816d3",
".git/objects/40/ba33fd420f772537e9176ce72e6a55e23fe5ad": "c3d8900cf6befaab01341dbf27648798",
".git/objects/41/c460bd32a19ee800fd276f1a42c98ea0d89a87": "44210f1c526eb939fbf9223498821c88",
".git/objects/43/3e70de6decb4dcc7276f1fb683b0f5fb85f195": "8e47776a7f265126b9dfefdbf9d06682",
".git/objects/44/25d15a318f39cf3c684d3556af92f6f1edc27a": "f77ded06aa29207ccaed15bcb4fd4038",
".git/objects/44/5ae089c28c90ca43b6e7a4af165330397f7e13": "1e36982a6b2955dadb05c27ed81db030",
".git/objects/45/1f2c30d3cf4fbb0419db30a640ee20b93fabff": "3ee66d90ec316fe5adc161a4ccac1f9f",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/47/add9f531b83882a2eac7c276aa75f7a1446fd2": "786cc595e63e9e3b3ce611db3f0c693f",
".git/objects/4a/39079e580dc9be820cba2fae41238c49eaa798": "ada1a19fea32fbb6719120809b9eae60",
".git/objects/4f/e6b664426eefcc8a763b79e879cf1a67f60255": "eefc3e52d4ab13677a9498cd5f653903",
".git/objects/54/a13801ae4ffb06aedfb993e86c0a8503fa5d70": "425d1075e43442da40f69ed1c741d99d",
".git/objects/55/11e38e9e903f75eaafcc5abd833435b53bb390": "eab1d7740fde7afe7af25f06f92e94c4",
".git/objects/56/e25ef5a2b2d473bc2298cae0abfe24e6544699": "76c137d2b79c363628b7844ca691b6c3",
".git/objects/57/374516d2cebd83749374d28a5bdeb0f1ac0575": "fca06953ac77fac15718cdfe46affbab",
".git/objects/57/a83afd9c86435accf2ccb49e53c2e526231567": "3db52cf75e22a4ff46dc1a2aa40b2cf5",
".git/objects/5a/7b05e1be311772247124911182fda78fde2cec": "d38bfbb93663df272dc4920186bd1040",
".git/objects/62/b94505b16caebfdd6764913d9eb839ffe2f03f": "33e243ae6974e3f8279eb477ec6a3f3c",
".git/objects/65/0334f7d11746b5e6733ba856b6c68ca0201418": "8d8c342b027989167f43a03797f2e946",
".git/objects/65/33244ab9742772c3dca5b3d3865000295347e9": "af5de5dc3532bcd6455e92d139b18a02",
".git/objects/66/0879f72f4cb9e594fbab62de317a9dc43c4c7c": "73aafc779ff83e3b4c2e9fda688cffe7",
".git/objects/66/7d9cd94790272cdf9ecdb7034736dbf0b5856c": "49abfac1b7edfc37f50f18254eece1c1",
".git/objects/69/dd618354fa4dade8a26e0fd18f5e87dd079236": "8cc17911af57a5f6dc0b9ee255bb1a93",
".git/objects/6d/4da57c15112fab04c1c31312fadb1bf7acd81f": "dc48f65cc5eb6218d3804c6dd4c1c21f",
".git/objects/6f/9cad4c116bc8d72e2497226abb5c05ee64982c": "0d104480d68c1652a53721377a02a882",
".git/objects/71/7117947090611c3967f8681ab1ac0f79bca7fc": "ad4e74c0da46020e04043b5cf7f91098",
".git/objects/71/7809363ed19bdd7e1d78f6e421e40a96bc29e3": "9414a3044cb191cc3f57340f57c3dc93",
".git/objects/76/a4d4da21aa7d6fd444e2de17ce8d4bd3c2edb3": "48d9b438e4e7611198e04dfac6a5a11d",
".git/objects/77/417c0a201dd0ca9149799df8e23d233d33c808": "0e37113f939adad00ff359f46d5dec6a",
".git/objects/78/d6844b124b5e7f857c1c09b49362023a461cd5": "4cbe6e4a3d63d8e19a97e5ee9a1474d7",
".git/objects/85/6680ee956230607f846b0320391d4755cdcf3d": "283b124ed7d659f5a679248dd7006c6b",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/89/994eb0c243420c8c28b15fc1ec25983d448732": "fb02c6305c3a3bb4dbf768b5e2cbcd44",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8f/e7af5a3e840b75b70e59c3ffda1b58e84a5a1c": "e3695ae5742d7e56a9c696f82745288d",
".git/objects/92/c02651ed6039d80a998bfd680a88a8451fb390": "86f6628f4da991e7e1662d1c43030a7e",
".git/objects/94/5eea037c2f92913ee3772656e7bea9c6b6948b": "83959c9b77089f066f89cd76390fd6da",
".git/objects/94/bfb1463ad8331bfd687bc751b8920b133da744": "fd2d8c0d844b234856b36b93f652048f",
".git/objects/96/341c8cf086d23c57dbc091ff5f5c4d71c0515e": "1473638718ae8060f793be87d4acb6cb",
".git/objects/9e/6df5a6e5a019db41b021800b0208c2c859b1ef": "624a5f7e70baf71b10550ec0866eb3f2",
".git/objects/a3/f2a5b85ed169f587d76b7df463414cabd283ad": "f080409efdcaf9dd2b159c37a1da2394",
".git/objects/a6/13a8848e74f95c10f1357285ae0d3234b20df0": "ad3c882d69de0ad8a11b02ab27950f4d",
".git/objects/aa/f27231b87b0a7665a941f294ab4bc4702882e0": "b3ffc59afd573c23e194d26eeb36395f",
".git/objects/ad/6caaa60c33cad4262d2bb0aa04dac12ada950c": "a1c48cb975e05eaf6dee39f4ce29e37e",
".git/objects/af/742adee0a85dd21ea96cbd84182e30e085d6cf": "aa25b932ec40efacb1efe27e7cf25d82",
".git/objects/b5/0254288cc6319d153c4af1d64870d95ee2436f": "468a6506934a07c970a4739eae75eedd",
".git/objects/b5/db17d52aa8712bb3313daaea6667b23ca4e291": "b1339f9273b937447fd0d42165f7d05a",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/51113cd552c6ae59753d9e2b7d8e5b8f35429c": "136c05d000f35ff0eea3287a75aad827",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/ba/d4125fd9a0459eb63c936b0bed32e81f370928": "36a89a7fd07f49c627377d854f27104d",
".git/objects/bb/0cc413c6b290f75bb10b99beb6e1f84ae7b330": "4f142ce30ef836ece26ab0f7f075d0ef",
".git/objects/c5/f4bc2a4da91586f3005813077f0d0aa9040f82": "3191028b787554cee4652f5050144bff",
".git/objects/c7/7d77ff105e9801553e71cf55fabe4c559d3153": "7ff600fab769f40d5576cd07e98515b0",
".git/objects/d1/ddefcfcf6795481b0c154c396b80a6588cd605": "50c69145885e5127db71fed707a8d8b5",
".git/objects/d3/a030d40ab00fe41203c2e9859811f562e5291d": "153b27856d8ec7e649f3eb0b3d354c47",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/de/2396585655bb4982d591f360dd7d4790de8dc6": "e0897353905abcef7eef8bf2537e6f32",
".git/objects/e1/0c99e9b6e010a7652148697b529b0902b85dce": "4b758dc4d01a20df57341353c192b496",
".git/objects/e6/9de29bb2d1d6434b8b29ae775ad8c2e48c5391": "c70c34cbeefd40e7c0149b7a0c2c64c2",
".git/objects/e8/2c5850db3a3482d0c954a4dc122c02de555ce7": "d357cd906b3805bf81477f5527cca086",
".git/objects/e9/f3508356717b33394b8b90010118c8bd4a5b43": "cfcf13703e4b62e1aa36237c4eca2677",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/f4d9312d96e8a0a4a263c3877467a0f8c51402": "2788e706424830f278627c4f399fea4d",
".git/objects/ee/f3fbb0a4548298e0cf2ccb5a27bdae2af91881": "89beba2deb1e49083b8fe4120ecbeeb2",
".git/objects/f0/5458ca3077311d708559eac6b368544ea4d44f": "0b2059eeec705328599334342e9822e7",
".git/objects/f1/7330a97557330008ca07bb53eda53539300e87": "d100a314c0c42569ff5ba7dd727f41a3",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f2/81e7a8c0c81b60552d9836bdb93462ee486ced": "4013351f2f48d3f2a7949c00480d5c3c",
".git/ORIG_HEAD": "adb5ed0c7af375f3b9b8d3c1f5df9f28",
".git/refs/heads/gh-pages": "5ac7ad4cefda2135e344d5378819234b",
".git/refs/remotes/origin/gh-pages": "5ac7ad4cefda2135e344d5378819234b",
"assets/AssetManifest.bin": "91edd3ebaabbfcf62306e5920664837d",
"assets/AssetManifest.bin.json": "ab642fb6c9ab75bd5269430d88f8e6da",
"assets/AssetManifest.json": "a8e063eb3b90b27b0e448fad4f2c2aab",
"assets/assets/images/LogoManillasMagicas.png": "8eca18ed59c365403fed005d5df7d971",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "53ea13e10c10c843c08addd10c71ad2e",
"assets/NOTICES": "1678299091b15145388b2293359334bd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"CNAME": "fd85921f3218ffff83bbe8e6253e254e",
"CNAME.txt": "d41d8cd98f00b204e9800998ecf8427e",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "bc8a1d7112a32a35f48c96e6f6a9d049",
"/": "bc8a1d7112a32a35f48c96e6f6a9d049",
"main.dart.js": "471916309eabc00fccc03d6f47e0b911",
"manifest.json": "8145fd332b902c45528a0dbe4c2fcc23",
"version.json": "cbe32c80d5414639882d5a23052829b3"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
