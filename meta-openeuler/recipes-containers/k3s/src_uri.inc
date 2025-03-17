# bazil.org/fuse v0.0.0-20160811212531-371fbbdaa898
# [1] git ls-remote https://github.com/bazil/fuse 371fbbdaa8987b715bdd21d6adc4c9b20155f748 
SRCREV_fuse="371fbbdaa8987b715bdd21d6adc4c9b20155f748"
SRC_URI += "git://github.com/bazil/fuse;name=fuse;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/bazil/fuse"

# bitbucket.org/bertimus9/systemstat v0.0.0-20180207000608-0eeff89b0690
# [1] git ls-remote https://bitbucket.org/bertimus9/systemstat 0eeff89b0690611fc32e21f0cd2e4434abf8fe53 
SRCREV_systemstat="0eeff89b0690611fc32e21f0cd2e4434abf8fe53"
SRC_URI += "git://bitbucket.org/bertimus9/systemstat;name=systemstat;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/bitbucket.org/bertimus9/systemstat"

# cloud.google.com/go v0.97.0
# [1] git ls-remote https://github.com/googleapis/google-cloud-go 26286e362470c1b4e60e33d07cb2e12b62843ed7 
SRCREV_go="26286e362470c1b4e60e33d07cb2e12b62843ed7"
SRC_URI += "git://github.com/googleapis/google-cloud-go;name=go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/googleapis/google-cloud-go"

# cloud.google.com/go/bigquery v1.8.0
# [1] git ls-remote https://github.com/googleapis/google-cloud-go b3945009be381cc70ed324060d32bb109af42b18 
SRCREV_bigquery="b3945009be381cc70ed324060d32bb109af42b18"
SRC_URI += "git://github.com/googleapis/google-cloud-go;name=bigquery;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/googleapis/google-cloud-go/bigquery"

# dmitri.shuralyov.com/gpu/mtl v0.0.0-20201218220906-28db891af037
# [1] git ls-remote https://dmitri.shuralyov.com/gpu/mtl 28db891af037715d8c1deec7652485a173c60e25 
SRCREV_mtl="28db891af037715d8c1deec7652485a173c60e25"
SRC_URI += "git://dmitri.shuralyov.com/gpu/mtl;name=mtl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/dmitri.shuralyov.com/gpu/mtl"

# github.com/360EntSecGroup-Skylar/excelize v1.4.1
# [1] git ls-remote https://github.com/360EntSecGroup-Skylar/excelize dea7ba0ec43a4c29a6642d02b6edc73b8b0369f0 
SRCREV_excelize="dea7ba0ec43a4c29a6642d02b6edc73b8b0369f0"
SRC_URI += "git://github.com/360EntSecGroup-Skylar/excelize;name=excelize;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/360EntSecGroup-Skylar/excelize"

# github.com/Azure/azure-sdk-for-go v55.0.0+incompatible
# [1] git ls-remote https://github.com/Azure/azure-sdk-for-go 3640559afddbad452d265b54fb1c20b30be0b062 
SRCREV_azure-sdk-for-go="3640559afddbad452d265b54fb1c20b30be0b062"
SRC_URI += "git://github.com/Azure/azure-sdk-for-go;name=azure-sdk-for-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/azure-sdk-for-go"

# github.com/Azure/go-ansiterm v0.0.0-20210617225240-d185dfc1b5a1
# [1] git ls-remote https://github.com/Azure/go-ansiterm d185dfc1b5a126116ea5a19e148e29d16b4574c9 
SRCREV_go-ansiterm="d185dfc1b5a126116ea5a19e148e29d16b4574c9"
SRC_URI += "git://github.com/Azure/go-ansiterm;name=go-ansiterm;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-ansiterm"

# github.com/Azure/go-autorest v14.2.0+incompatible
# [1] git ls-remote https://github.com/Azure/go-autorest e7b391b759b050d6719cc6fd8bb87b6dc038bca6 
SRCREV_go-autorest="e7b391b759b050d6719cc6fd8bb87b6dc038bca6"
SRC_URI += "git://github.com/Azure/go-autorest;name=go-autorest;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest"

# github.com/Azure/go-autorest/autorest v0.11.18
# [1] git ls-remote https://github.com/Azure/go-autorest 7dd32b67be4e6c9386b9ba7b1c44a51263f05270 
SRCREV_autorest="7dd32b67be4e6c9386b9ba7b1c44a51263f05270"
SRC_URI += "git://github.com/Azure/go-autorest;name=autorest;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Azure/go-autorest/autorest"

# github.com/BurntSushi/toml v0.4.1
# [1] git ls-remote https://github.com/BurntSushi/toml f8ffb34d6924aa5f450dacce4c2146a1c9fc7253 
SRCREV_toml="f8ffb34d6924aa5f450dacce4c2146a1c9fc7253"
SRC_URI += "git://github.com/BurntSushi/toml;name=toml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/BurntSushi/toml"

# github.com/BurntSushi/xgb v0.0.0-20160522181843-27f122750802
# [1] git ls-remote https://github.com/BurntSushi/xgb 27f122750802c950b2c869a5b63dafcf590ced95 
SRCREV_xgb="27f122750802c950b2c869a5b63dafcf590ced95"
SRC_URI += "git://github.com/BurntSushi/xgb;name=xgb;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/BurntSushi/xgb"

# github.com/GoogleCloudPlatform/k8s-cloud-provider v0.0.0-20200415212048-7901bc822317
# [1] git ls-remote https://github.com/GoogleCloudPlatform/k8s-cloud-provider 7901bc822317c56ff20e5189878966a70d52321e 
SRCREV_k8s-cloud-provider="7901bc822317c56ff20e5189878966a70d52321e"
SRC_URI += "git://github.com/GoogleCloudPlatform/k8s-cloud-provider;name=k8s-cloud-provider;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/GoogleCloudPlatform/k8s-cloud-provider"

# github.com/JeffAshton/win_pdh v0.0.0-20161109143554-76bb4ee9f0ab
# [1] git ls-remote https://github.com/JeffAshton/win_pdh 76bb4ee9f0ab50f77826f2a2ee7fb9d3880d6ec2 
SRCREV_win_pdh="76bb4ee9f0ab50f77826f2a2ee7fb9d3880d6ec2"
SRC_URI += "git://github.com/JeffAshton/win_pdh;name=win_pdh;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/JeffAshton/win_pdh"

# github.com/MakeNowJust/heredoc v0.0.0-20170808103936-bb23615498cd
# [1] git ls-remote https://github.com/MakeNowJust/heredoc bb23615498cded5e105af4ce27de75b089cbe851 
SRCREV_heredoc="bb23615498cded5e105af4ce27de75b089cbe851"
SRC_URI += "git://github.com/MakeNowJust/heredoc;name=heredoc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/MakeNowJust/heredoc"

# github.com/Microsoft/go-winio v0.5.0
# [1] git ls-remote https://github.com/Microsoft/go-winio 58dba89befbca5b5a2c944f84642f5b0540bcfd5 
SRCREV_go-winio="58dba89befbca5b5a2c944f84642f5b0540bcfd5"
SRC_URI += "git://github.com/Microsoft/go-winio;name=go-winio;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Microsoft/go-winio"

# github.com/Microsoft/hcsshim v0.8.20
# [1] git ls-remote https://github.com/Microsoft/hcsshim 3ad51c76263bad09548a40e1996960814a12a870 
SRCREV_hcsshim="3ad51c76263bad09548a40e1996960814a12a870"
SRC_URI += "git://github.com/Microsoft/hcsshim;name=hcsshim;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Microsoft/hcsshim"

# github.com/NYTimes/gziphandler v1.1.1
# [1] git ls-remote https://github.com/NYTimes/gziphandler dd0439581c7657cb652dfe5c71d7d48baf39541d 
SRCREV_gziphandler="dd0439581c7657cb652dfe5c71d7d48baf39541d"
SRC_URI += "git://github.com/NYTimes/gziphandler;name=gziphandler;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/NYTimes/gziphandler"

# github.com/OneOfOne/xxhash v1.2.2
# [1] git ls-remote https://github.com/OneOfOne/xxhash 6def279d2ce6c81a79dd1c1be580f03bb216fb8a 
SRCREV_xxhash="6def279d2ce6c81a79dd1c1be580f03bb216fb8a"
SRC_URI += "git://github.com/OneOfOne/xxhash;name=xxhash;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/OneOfOne/xxhash"

# github.com/PuerkitoBio/goquery v1.5.0
# [1] git ls-remote https://github.com/PuerkitoBio/goquery 2d2796f41742ece03e8086188fa4db16a3a0b458 
SRCREV_goquery="2d2796f41742ece03e8086188fa4db16a3a0b458"
SRC_URI += "git://github.com/PuerkitoBio/goquery;name=goquery;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/PuerkitoBio/goquery"

# github.com/PuerkitoBio/purell v1.1.1
# [1] git ls-remote https://github.com/PuerkitoBio/purell 44968752391892e1b0d0b821ee79e9a85fa13049 
SRCREV_purell="44968752391892e1b0d0b821ee79e9a85fa13049"
SRC_URI += "git://github.com/PuerkitoBio/purell;name=purell;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/PuerkitoBio/purell"

# github.com/PuerkitoBio/urlesc v0.0.0-20170810143723-de5bf2ad4578
# [1] git ls-remote https://github.com/PuerkitoBio/urlesc de5bf2ad457846296e2031421a34e2568e304e35 
SRCREV_urlesc="de5bf2ad457846296e2031421a34e2568e304e35"
SRC_URI += "git://github.com/PuerkitoBio/urlesc;name=urlesc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/PuerkitoBio/urlesc"

# github.com/Rican7/retry v0.1.0
# [1] git ls-remote https://github.com/Rican7/retry af41d8e8dc050fe4ad27246530a187a1ce601b95 
SRCREV_retry="af41d8e8dc050fe4ad27246530a187a1ce601b95"
SRC_URI += "git://github.com/Rican7/retry;name=retry;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/Rican7/retry"

# github.com/agnivade/levenshtein v1.0.1
# [1] git ls-remote https://github.com/agnivade/levenshtein 834b435c3df04fba060c8d74a40d849ab2c4a090 
SRCREV_levenshtein="834b435c3df04fba060c8d74a40d849ab2c4a090"
SRC_URI += "git://github.com/agnivade/levenshtein;name=levenshtein;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/agnivade/levenshtein"

# github.com/ajstarks/svgo v0.0.0-20180226025133-644b8db467af
# [1] git ls-remote https://github.com/ajstarks/svgo 644b8db467afccf19a0692a3e31a1868e4287ab8 
SRCREV_svgo="644b8db467afccf19a0692a3e31a1868e4287ab8"
SRC_URI += "git://github.com/ajstarks/svgo;name=svgo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ajstarks/svgo"

# github.com/alecthomas/template v0.0.0-20190718012654-fb15b899a751
# [1] git ls-remote https://github.com/alecthomas/template fb15b899a75114aa79cc930e33c46b577cc664b1 
SRCREV_template="fb15b899a75114aa79cc930e33c46b577cc664b1"
SRC_URI += "git://github.com/alecthomas/template;name=template;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/alecthomas/template"

# github.com/alecthomas/units v0.0.0-20190924025748-f65c72e2690d
# [1] git ls-remote https://github.com/alecthomas/units f65c72e2690dc4b403c8bd637baf4611cd4c069b 
SRCREV_units="f65c72e2690dc4b403c8bd637baf4611cd4c069b"
SRC_URI += "git://github.com/alecthomas/units;name=units;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/alecthomas/units"

# github.com/alexflint/go-filemutex v0.0.0-20171022225611-72bdc8eae2ae
# [1] git ls-remote https://github.com/alexflint/go-filemutex 72bdc8eae2aef913234599b837f5dda445ca9bd9 
SRCREV_go-filemutex="72bdc8eae2aef913234599b837f5dda445ca9bd9"
SRC_URI += "git://github.com/alexflint/go-filemutex;name=go-filemutex;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/alexflint/go-filemutex"

# github.com/andreyvit/diff v0.0.0-20170406064948-c7f18ee00883
# [1] git ls-remote https://github.com/andreyvit/diff c7f18ee00883bfd3b00e0a2bf7607827e0148ad4 
SRCREV_diff="c7f18ee00883bfd3b00e0a2bf7607827e0148ad4"
SRC_URI += "git://github.com/andreyvit/diff;name=diff;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/andreyvit/diff"

# github.com/andybalholm/cascadia v1.0.0
# [1] git ls-remote https://github.com/andybalholm/cascadia 901648c87902174f774fac311d7f176f8647bdaa 
SRCREV_cascadia="901648c87902174f774fac311d7f176f8647bdaa"
SRC_URI += "git://github.com/andybalholm/cascadia;name=cascadia;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/andybalholm/cascadia"

# github.com/antihax/optional v1.0.0
# [1] git ls-remote https://github.com/antihax/optional c3f0ba9c1a592b971d66b2787679af55b5c58f21 
SRCREV_optional="c3f0ba9c1a592b971d66b2787679af55b5c58f21"
SRC_URI += "git://github.com/antihax/optional;name=optional;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/antihax/optional"

# github.com/armon/circbuf v0.0.0-20150827004946-bbbad097214e
# [1] git ls-remote https://github.com/armon/circbuf bbbad097214e2918d8543d5201d12bfd7bca254d 
SRCREV_circbuf="bbbad097214e2918d8543d5201d12bfd7bca254d"
SRC_URI += "git://github.com/armon/circbuf;name=circbuf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/armon/circbuf"

# github.com/armon/consul-api v0.0.0-20180202201655-eb2c6b5be1b6
# [1] git ls-remote https://github.com/armon/consul-api eb2c6b5be1b66bab83016e0b05f01b8d5496ffbd 
SRCREV_consul-api="eb2c6b5be1b66bab83016e0b05f01b8d5496ffbd"
SRC_URI += "git://github.com/armon/consul-api;name=consul-api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/armon/consul-api"

# github.com/armon/go-metrics v0.0.0-20180917152333-f0300d1749da
# [1] git ls-remote https://github.com/armon/go-metrics f0300d1749da6fa982027e449ec0c7a145510c3c 
SRCREV_go-metrics="f0300d1749da6fa982027e449ec0c7a145510c3c"
SRC_URI += "git://github.com/armon/go-metrics;name=go-metrics;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/armon/go-metrics"

# github.com/armon/go-radix v0.0.0-20180808171621-7fddfc383310
# [1] git ls-remote https://github.com/armon/go-radix 7fddfc383310abc091d79a27f116d30cf0424032 
SRCREV_go-radix="7fddfc383310abc091d79a27f116d30cf0424032"
SRC_URI += "git://github.com/armon/go-radix;name=go-radix;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/armon/go-radix"

# github.com/asaskevich/govalidator v0.0.0-20190424111038-f61b66f89f4a
# [1] git ls-remote https://github.com/asaskevich/govalidator f61b66f89f4a311bef65f13e575bcf1a2ffadda6 
SRCREV_govalidator="f61b66f89f4a311bef65f13e575bcf1a2ffadda6"
SRC_URI += "git://github.com/asaskevich/govalidator;name=govalidator;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/asaskevich/govalidator"

# github.com/auth0/go-jwt-middleware v1.0.1
# [1] git ls-remote https://github.com/auth0/go-jwt-middleware dec8d9f66d0b99d1085a060812cd13d7219a7ebd 
SRCREV_go-jwt-middleware="dec8d9f66d0b99d1085a060812cd13d7219a7ebd"
SRC_URI += "git://github.com/auth0/go-jwt-middleware;name=go-jwt-middleware;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/auth0/go-jwt-middleware"

# github.com/aws/aws-sdk-go v1.38.70
# [1] git ls-remote https://github.com/aws/aws-sdk-go c2c371dfc5c3306bf6e7bec6cc75054a9f205c21 
SRCREV_aws-sdk-go="c2c371dfc5c3306bf6e7bec6cc75054a9f205c21"
SRC_URI += "git://github.com/aws/aws-sdk-go;name=aws-sdk-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/aws/aws-sdk-go"

# github.com/benbjohnson/clock v1.0.3
# [1] git ls-remote https://github.com/benbjohnson/clock d30813fdb557385ec7cbe73036752baa31e72664 
SRCREV_clock="d30813fdb557385ec7cbe73036752baa31e72664"
SRC_URI += "git://github.com/benbjohnson/clock;name=clock;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/benbjohnson/clock"

# github.com/beorn7/perks v1.0.1
# [1] git ls-remote https://github.com/beorn7/perks c49ff274687222a7373c4cd83578f1065cf3e143 
SRCREV_perks="c49ff274687222a7373c4cd83578f1065cf3e143"
SRC_URI += "git://github.com/beorn7/perks;name=perks;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/beorn7/perks"

# github.com/bgentry/speakeasy v0.1.0
# [1] git ls-remote https://github.com/bgentry/speakeasy 12abe455afa69a18b1098acb18b1f004a4a6c33c 
SRCREV_speakeasy="12abe455afa69a18b1098acb18b1f004a4a6c33c"
SRC_URI += "git://github.com/bgentry/speakeasy;name=speakeasy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/bgentry/speakeasy"

# github.com/bits-and-blooms/bitset v1.2.0
# [1] git ls-remote https://github.com/bits-and-blooms/bitset 59de210119f50cedaa42d175dc88b6335fcf63f6 
SRCREV_bitset="59de210119f50cedaa42d175dc88b6335fcf63f6"
SRC_URI += "git://github.com/bits-and-blooms/bitset;name=bitset;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/bits-and-blooms/bitset"

# github.com/bketelsen/crypt v0.0.4
# [1] git ls-remote https://github.com/bketelsen/crypt 3f0829aaee54a3e9eabd45afbf68257a5cf754f7 
SRCREV_crypt="3f0829aaee54a3e9eabd45afbf68257a5cf754f7"
SRC_URI += "git://github.com/bketelsen/crypt;name=crypt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/bketelsen/crypt"

# github.com/blang/semver v3.5.1+incompatible
# [1] git ls-remote https://github.com/blang/semver 2ee87856327ba09384cabd113bc6b5d174e9ec0f 
SRCREV_semver="2ee87856327ba09384cabd113bc6b5d174e9ec0f"
SRC_URI += "git://github.com/blang/semver;name=semver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/blang/semver"

# github.com/boltdb/bolt v1.3.1
# [1] git ls-remote https://github.com/boltdb/bolt 2f1ce7a837dcb8da3ec595b1dac9d0632f0f99e8 
SRCREV_bolt="2f1ce7a837dcb8da3ec595b1dac9d0632f0f99e8"
SRC_URI += "git://github.com/boltdb/bolt;name=bolt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/boltdb/bolt"

# github.com/bronze1man/goStrongswanVici v0.0.0-20201105010758-936f38b697fd
# [1] git ls-remote https://github.com/bronze1man/goStrongswanVici 936f38b697fd9a0054eee1469fee9d51199d4e66 
SRCREV_goStrongswanVici="936f38b697fd9a0054eee1469fee9d51199d4e66"
SRC_URI += "git://github.com/bronze1man/goStrongswanVici;name=goStrongswanVici;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/bronze1man/goStrongswanVici"

# github.com/buger/jsonparser v0.0.0-20180808090653-f4dd9f5a6b44
# [1] git ls-remote https://github.com/buger/jsonparser f4dd9f5a6b441265aefc1d44872a6f8c10f42b37 
SRCREV_jsonparser="f4dd9f5a6b441265aefc1d44872a6f8c10f42b37"
SRC_URI += "git://github.com/buger/jsonparser;name=jsonparser;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/buger/jsonparser"

# github.com/canonical/go-dqlite v1.5.1
# [1] git ls-remote https://github.com/canonical/go-dqlite 830c1a017995b73322e86c2a6f2ca799c1caca07 
SRCREV_go-dqlite="830c1a017995b73322e86c2a6f2ca799c1caca07"
SRC_URI += "git://github.com/canonical/go-dqlite;name=go-dqlite;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/canonical/go-dqlite"

# github.com/census-instrumentation/opencensus-proto v0.2.1
# [1] git ls-remote https://github.com/census-instrumentation/opencensus-proto 69cb099384edf046119a59a69761efa7042fbeb4 
SRCREV_opencensus-proto="69cb099384edf046119a59a69761efa7042fbeb4"
SRC_URI += "git://github.com/census-instrumentation/opencensus-proto;name=opencensus-proto;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/census-instrumentation/opencensus-proto"

# github.com/certifi/gocertifi v0.0.0-20200922220541-2c3bb06c6054
# [1] git ls-remote https://github.com/certifi/gocertifi 2c3bb06c6054e133430498817d26ac003d08f020 
SRCREV_gocertifi="2c3bb06c6054e133430498817d26ac003d08f020"
SRC_URI += "git://github.com/certifi/gocertifi;name=gocertifi;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/certifi/gocertifi"

# github.com/cespare/xxhash v1.1.0
# [1] git ls-remote https://github.com/cespare/xxhash 569f7c8abf1f58d9043ab804d364483cb1c853b6 
SRCREV_xxhash1="569f7c8abf1f58d9043ab804d364483cb1c853b6"
SRC_URI += "git://github.com/cespare/xxhash;name=xxhash1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cespare/xxhash"

# github.com/cespare/xxhash/v2 v2.1.1
# [1] git ls-remote https://github.com/cespare/xxhash 68d2e6187fda44f45b905aeeebdb40a73d137ea1 
SRCREV_v2="68d2e6187fda44f45b905aeeebdb40a73d137ea1"
SRC_URI += "git://github.com/cespare/xxhash;name=v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cespare/xxhash/v2"

# github.com/chai2010/gettext-go v0.0.0-20160711120539-c6fed771bfd5
# [1] git ls-remote https://github.com/chai2010/gettext-go c6fed771bfd517099caf0f7a961671fa8ed08723 
SRCREV_gettext-go="c6fed771bfd517099caf0f7a961671fa8ed08723"
SRC_URI += "git://github.com/chai2010/gettext-go;name=gettext-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/chai2010/gettext-go"

# github.com/checkpoint-restore/go-criu/v5 v5.0.0
# [1] git ls-remote https://github.com/checkpoint-restore/go-criu 885cc36edb02fc5afeed0759885b473c16d249d8 
SRCREV_v5="885cc36edb02fc5afeed0759885b473c16d249d8"
SRC_URI += "git://github.com/checkpoint-restore/go-criu;name=v5;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/checkpoint-restore/go-criu/v5"

# github.com/cheggaaa/pb v1.0.29
# [1] git ls-remote https://github.com/cheggaaa/pb e2a33cc368a206516cc95f7bdd9176db0b83f098 
SRCREV_pb="e2a33cc368a206516cc95f7bdd9176db0b83f098"
SRC_URI += "git://github.com/cheggaaa/pb;name=pb;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cheggaaa/pb"

# github.com/chzyer/logex v1.1.10
# [1] git ls-remote https://github.com/chzyer/logex cd112f618178aaaf4ea8592c8839f5276145d9cf 
SRCREV_logex="cd112f618178aaaf4ea8592c8839f5276145d9cf"
SRC_URI += "git://github.com/chzyer/logex;name=logex;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/chzyer/logex"

# github.com/chzyer/readline v0.0.0-20180603132655-2972be24d48e
# [1] git ls-remote https://github.com/chzyer/readline 2972be24d48e78746da79ba8e24e8b488c9880de 
SRCREV_readline="2972be24d48e78746da79ba8e24e8b488c9880de"
SRC_URI += "git://github.com/chzyer/readline;name=readline;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/chzyer/readline"

# github.com/chzyer/test v0.0.0-20180213035817-a1ea475d72b1
# [1] git ls-remote https://github.com/chzyer/test a1ea475d72b168a29f44221e0ad031a842642302 
SRCREV_test="a1ea475d72b168a29f44221e0ad031a842642302"
SRC_URI += "git://github.com/chzyer/test;name=test;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/chzyer/test"

# github.com/cilium/ebpf v0.7.0
# [1] git ls-remote https://github.com/cilium/ebpf 13667bdb8f164c32ae1b85e7130552dd93e86dfd 
SRCREV_ebpf="13667bdb8f164c32ae1b85e7130552dd93e86dfd"
SRC_URI += "git://github.com/cilium/ebpf;name=ebpf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cilium/ebpf"

# github.com/cloudnativelabs/kube-router v1.3.2
# [1] git ls-remote https://github.com/cloudnativelabs/kube-router 6ed5596ff731b42c6a3bda87835a96afe338e1d2 
SRCREV_kube-router="6ed5596ff731b42c6a3bda87835a96afe338e1d2"
SRC_URI += "git://github.com/cloudnativelabs/kube-router;name=kube-router;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cloudnativelabs/kube-router"

# github.com/clusterhq/flocker-go v0.0.0-20160920122132-2b8b7259d313
# [1] git ls-remote https://github.com/clusterhq/flocker-go 2b8b7259d3139c96c4a6871031355808ab3fd3b3 
SRCREV_flocker-go="2b8b7259d3139c96c4a6871031355808ab3fd3b3"
SRC_URI += "git://github.com/clusterhq/flocker-go;name=flocker-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/clusterhq/flocker-go"

# github.com/cncf/udpa/go v0.0.0-20201120205902-5459f2c99403
# [1] git ls-remote https://github.com/cncf/udpa 5459f2c994033b0afed7e4a70ac7e90c90c1ffee 
SRCREV_go1="5459f2c994033b0afed7e4a70ac7e90c90c1ffee"
SRC_URI += "git://github.com/cncf/udpa;name=go1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cncf/udpa/go"

# github.com/cockroachdb/datadriven v0.0.0-20200714090401-bf6692d28da5
# [1] git ls-remote https://github.com/cockroachdb/datadriven bf6692d28da5d6c6dade56f0c2679ca87705e1ad 
SRCREV_datadriven="bf6692d28da5d6c6dade56f0c2679ca87705e1ad"
SRC_URI += "git://github.com/cockroachdb/datadriven;name=datadriven;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cockroachdb/datadriven"

# github.com/cockroachdb/errors v1.2.4
# [1] git ls-remote https://github.com/cockroachdb/errors 9e21257b06ad938e53c24c52b393076a51b61540 
SRCREV_errors="9e21257b06ad938e53c24c52b393076a51b61540"
SRC_URI += "git://github.com/cockroachdb/errors;name=errors;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cockroachdb/errors"

# github.com/cockroachdb/logtags v0.0.0-20190617123548-eb05cc24525f
# [1] git ls-remote https://github.com/cockroachdb/logtags eb05cc24525fa45bcdbaaeec3e431a82099f9ad4 
SRCREV_logtags="eb05cc24525fa45bcdbaaeec3e431a82099f9ad4"
SRC_URI += "git://github.com/cockroachdb/logtags;name=logtags;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cockroachdb/logtags"

# github.com/container-storage-interface/spec v1.5.0
# [1] git ls-remote https://github.com/container-storage-interface/spec f1ae02418ccc363f089ee952d438f30ffdb4b4dc 
SRCREV_spec="f1ae02418ccc363f089ee952d438f30ffdb4b4dc"
SRC_URI += "git://github.com/container-storage-interface/spec;name=spec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/container-storage-interface/spec"

# github.com/containerd/aufs v1.0.0
# [1] git ls-remote https://github.com/containerd/aufs 7dffc75339ca1cecb6de8a275ec8cee94e0ed855 
SRCREV_aufs="7dffc75339ca1cecb6de8a275ec8cee94e0ed855"
SRC_URI += "git://github.com/containerd/aufs;name=aufs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/aufs"

# github.com/containerd/btrfs v1.0.0
# [1] git ls-remote https://github.com/containerd/btrfs ecd3a1e4f05ca245081bbaeaff5b3acff9e97c6a 
SRCREV_btrfs="ecd3a1e4f05ca245081bbaeaff5b3acff9e97c6a"
SRC_URI += "git://github.com/containerd/btrfs;name=btrfs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/btrfs"

# github.com/containerd/cgroups v1.0.1
# [1] git ls-remote https://github.com/containerd/cgroups 198bd73e83ff6bdebc18b1a356bf99df2436140f 
SRCREV_cgroups="198bd73e83ff6bdebc18b1a356bf99df2436140f"
SRC_URI += "git://github.com/containerd/cgroups;name=cgroups;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/cgroups"

# github.com/containerd/console v1.0.2
# [1] git ls-remote https://github.com/containerd/console d5efa7d56fd239f7f3dad2ab6685db09359a3618 
SRCREV_console="d5efa7d56fd239f7f3dad2ab6685db09359a3618"
SRC_URI += "git://github.com/containerd/console;name=console;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/console"

# github.com/k3s-io/containerd v1.5.9-k3s1
# [1] git ls-remote https://github.com/k3s-io/containerd d5a46d003e3079a0f4897fd97408409ab77b8e27 
SRCREV_containerd="d5a46d003e3079a0f4897fd97408409ab77b8e27"
SRC_URI += "git://github.com/k3s-io/containerd;name=containerd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/containerd"

# github.com/k3s-io/continuity v0.0.0-20210309170710-f93269e0d5c1
# [1] git ls-remote https://github.com/k3s-io/continuity f93269e0d5c1e116e1c7f1f5af80eae9a75f988b 
SRCREV_continuity="f93269e0d5c1e116e1c7f1f5af80eae9a75f988b"
SRC_URI += "git://github.com/k3s-io/continuity;name=continuity;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/continuity"

# github.com/containerd/fifo v1.0.0
# [1] git ls-remote https://github.com/containerd/fifo eb4e163db80cfde4102acfa62c87b2a37232c8a2 
SRCREV_fifo="eb4e163db80cfde4102acfa62c87b2a37232c8a2"
SRC_URI += "git://github.com/containerd/fifo;name=fifo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/fifo"

# github.com/containerd/fuse-overlayfs-snapshotter v1.0.4
# [1] git ls-remote https://github.com/containerd/fuse-overlayfs-snapshotter a4fb9d4458e8a700e55933024b650712b493f22f 
SRCREV_fuse-overlayfs-snapshotter="a4fb9d4458e8a700e55933024b650712b493f22f"
SRC_URI += "git://github.com/containerd/fuse-overlayfs-snapshotter;name=fuse-overlayfs-snapshotter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/fuse-overlayfs-snapshotter"

# github.com/containerd/go-cni v1.0.2
# [1] git ls-remote https://github.com/containerd/go-cni f1cbb273482be741efcf81da9eb69e3ab82a42cf 
SRCREV_go-cni="f1cbb273482be741efcf81da9eb69e3ab82a42cf"
SRC_URI += "git://github.com/containerd/go-cni;name=go-cni;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/go-cni"

# github.com/containerd/go-runc v1.0.0
# [1] git ls-remote https://github.com/containerd/go-runc 2b3d0644d70c637e0b2795aabbe15c89770d85b9 
SRCREV_go-runc="2b3d0644d70c637e0b2795aabbe15c89770d85b9"
SRC_URI += "git://github.com/containerd/go-runc;name=go-runc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/go-runc"

# github.com/containerd/imgcrypt v1.1.1
# [1] git ls-remote https://github.com/containerd/imgcrypt 93e954ac574d39a54b4e6a8e9e50b7ff4acee41c 
SRCREV_imgcrypt="93e954ac574d39a54b4e6a8e9e50b7ff4acee41c"
SRC_URI += "git://github.com/containerd/imgcrypt;name=imgcrypt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/imgcrypt"

# github.com/containerd/nri v0.1.0
# [1] git ls-remote https://github.com/containerd/nri cf90ff293408e9a021f738e73a8e0cee258e940a 
SRCREV_nri="cf90ff293408e9a021f738e73a8e0cee258e940a"
SRC_URI += "git://github.com/containerd/nri;name=nri;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/nri"

# github.com/containerd/stargz-snapshotter v0.10.1
# [1] git ls-remote https://github.com/containerd/stargz-snapshotter 91eb38acd4102d9e08edc3f583f7c18c6e614971 
SRCREV_stargz-snapshotter="91eb38acd4102d9e08edc3f583f7c18c6e614971"
SRC_URI += "git://github.com/containerd/stargz-snapshotter;name=stargz-snapshotter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/stargz-snapshotter"

# github.com/containerd/ttrpc v1.0.2
# [1] git ls-remote https://github.com/containerd/ttrpc bfba540dc45464586c106b1f31c8547933c1eb41 
SRCREV_ttrpc="bfba540dc45464586c106b1f31c8547933c1eb41"
SRC_URI += "git://github.com/containerd/ttrpc;name=ttrpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/ttrpc"

# github.com/containerd/typeurl v1.0.2
# [1] git ls-remote https://github.com/containerd/typeurl 9e1ad9a145b768c8f6bab9880513cd1b05fe5a20 
SRCREV_typeurl="9e1ad9a145b768c8f6bab9880513cd1b05fe5a20"
SRC_URI += "git://github.com/containerd/typeurl;name=typeurl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/typeurl"

# github.com/containerd/zfs v1.0.0
# [1] git ls-remote https://github.com/containerd/zfs 7d55686cf303446a33007780f9f008b281c8831c 
SRCREV_zfs="7d55686cf303446a33007780f9f008b281c8831c"
SRC_URI += "git://github.com/containerd/zfs;name=zfs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containerd/zfs"

# github.com/containernetworking/cni v0.8.1
# [1] git ls-remote https://github.com/containernetworking/cni 9fc34aee0a6396d6484992035819c92c42522eea 
SRCREV_cni="9fc34aee0a6396d6484992035819c92c42522eea"
SRC_URI += "git://github.com/containernetworking/cni;name=cni;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containernetworking/cni"

# github.com/containernetworking/plugins v0.9.1
# [1] git ls-remote https://github.com/containernetworking/plugins acf137b1f7e1c9f9bf1511ec938ed0aca7841f80 
SRCREV_plugins="acf137b1f7e1c9f9bf1511ec938ed0aca7841f80"
SRC_URI += "git://github.com/containernetworking/plugins;name=plugins;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containernetworking/plugins"

# github.com/containers/ocicrypt v1.1.1
# [1] git ls-remote https://github.com/containers/ocicrypt c989c0bcefa41e177f5d9f2f3182a7da13df0621 
SRCREV_ocicrypt="c989c0bcefa41e177f5d9f2f3182a7da13df0621"
SRC_URI += "git://github.com/containers/ocicrypt;name=ocicrypt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/containers/ocicrypt"

# github.com/coredns/caddy v1.1.0
# [1] git ls-remote https://github.com/coredns/caddy 115eb7dee367f3ee1907bc3d84d6aa7a7cd193d8 
SRCREV_caddy="115eb7dee367f3ee1907bc3d84d6aa7a7cd193d8"
SRC_URI += "git://github.com/coredns/caddy;name=caddy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coredns/caddy"

# github.com/coredns/corefile-migration v1.0.12
# [1] git ls-remote https://github.com/coredns/corefile-migration a17d727a232d5836eba83d558b94d73331b0f6c1 
SRCREV_corefile-migration="a17d727a232d5836eba83d558b94d73331b0f6c1"
SRC_URI += "git://github.com/coredns/corefile-migration;name=corefile-migration;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coredns/corefile-migration"

# github.com/coreos/bbolt v1.3.2
# [1] git ls-remote https://github.com/coreos/bbolt 63597a96ec0ad9e6d43c3fc81e809909e0237461 
SRCREV_bbolt="63597a96ec0ad9e6d43c3fc81e809909e0237461"
SRC_URI += "git://github.com/coreos/bbolt;name=bbolt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/bbolt"

# github.com/coreos/etcd v3.3.13+incompatible
# [1] git ls-remote https://github.com/coreos/etcd 1aa3d4036677a2e4e0d024177446f6459f0e1ea1 
SRCREV_etcd="1aa3d4036677a2e4e0d024177446f6459f0e1ea1"
SRC_URI += "git://github.com/coreos/etcd;name=etcd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/etcd"

# github.com/coreos/go-iptables v0.6.0
# [1] git ls-remote https://github.com/coreos/go-iptables 14d56d57c892f27a717aa6026fd2d3293221395b 
SRCREV_go-iptables="14d56d57c892f27a717aa6026fd2d3293221395b"
SRC_URI += "git://github.com/coreos/go-iptables;name=go-iptables;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-iptables"

# github.com/coreos/go-oidc v2.1.0+incompatible
# [1] git ls-remote https://github.com/coreos/go-oidc 2be1c5b8a260760503f66dc0996e102b683b3ac3 
SRCREV_go-oidc="2be1c5b8a260760503f66dc0996e102b683b3ac3"
SRC_URI += "git://github.com/coreos/go-oidc;name=go-oidc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-oidc"

# github.com/coreos/go-semver v0.3.0
# [1] git ls-remote https://github.com/coreos/go-semver 6e25b691b0ebe9657dd0ee60d73a9f8716f0c6f5 
SRCREV_go-semver="6e25b691b0ebe9657dd0ee60d73a9f8716f0c6f5"
SRC_URI += "git://github.com/coreos/go-semver;name=go-semver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-semver"

# github.com/coreos/go-systemd v0.0.0-20190321100706-95778dfbb74e
# [1] git ls-remote https://github.com/coreos/go-systemd 95778dfbb74eb7e4dbaf43bf7d71809650ef8076 
SRCREV_go-systemd="95778dfbb74eb7e4dbaf43bf7d71809650ef8076"
SRC_URI += "git://github.com/coreos/go-systemd;name=go-systemd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-systemd"

# github.com/coreos/go-systemd/v22 v22.3.2
# [1] git ls-remote https://github.com/coreos/go-systemd 0b40357fd65760243a3eceb80a299772c23c8470 
SRCREV_v22="0b40357fd65760243a3eceb80a299772c23c8470"
SRC_URI += "git://github.com/coreos/go-systemd;name=v22;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/go-systemd/v22"

# github.com/coreos/pkg v0.0.0-20180928190104-399ea9e2e55f
# [1] git ls-remote https://github.com/coreos/pkg 399ea9e2e55f791b6e3d920860dbecb99c3692f0 
SRCREV_pkg="399ea9e2e55f791b6e3d920860dbecb99c3692f0"
SRC_URI += "git://github.com/coreos/pkg;name=pkg;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/coreos/pkg"

# github.com/cpuguy83/go-md2man/v2 v2.0.1
# [1] git ls-remote https://github.com/cpuguy83/go-md2man b1ec32e02fe539480dc03e3bf381c20066e7c6cc 
SRCREV_v21="b1ec32e02fe539480dc03e3bf381c20066e7c6cc"
SRC_URI += "git://github.com/cpuguy83/go-md2man;name=v21;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cpuguy83/go-md2man/v2"

# github.com/creack/pty v1.1.11
# [1] git ls-remote https://github.com/creack/pty 2a38352e8b4d7ab6c336eef107e42a55e72e7fbc 
SRCREV_pty="2a38352e8b4d7ab6c336eef107e42a55e72e7fbc"
SRC_URI += "git://github.com/creack/pty;name=pty;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/creack/pty"

# github.com/cyphar/filepath-securejoin v0.2.2
# [1] git ls-remote https://github.com/cyphar/filepath-securejoin 6388e205e2047c305ff1a1e976b97523b8eeef9f 
SRCREV_filepath-securejoin="6388e205e2047c305ff1a1e976b97523b8eeef9f"
SRC_URI += "git://github.com/cyphar/filepath-securejoin;name=filepath-securejoin;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/cyphar/filepath-securejoin"

# github.com/d2g/dhcp4 v0.0.0-20170904100407-a1d1b6c41b1c
# [1] git ls-remote https://github.com/d2g/dhcp4 a1d1b6c41b1ce8a71a5121a9cee31809c4707d9c 
SRCREV_dhcp4="a1d1b6c41b1ce8a71a5121a9cee31809c4707d9c"
SRC_URI += "git://github.com/d2g/dhcp4;name=dhcp4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/d2g/dhcp4"

# github.com/d2g/dhcp4client v1.0.0
# [1] git ls-remote https://github.com/d2g/dhcp4client b7a004ff1a09ab6723625e179a44e476306977a6 
SRCREV_dhcp4client="b7a004ff1a09ab6723625e179a44e476306977a6"
SRC_URI += "git://github.com/d2g/dhcp4client;name=dhcp4client;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/d2g/dhcp4client"

# github.com/d2g/dhcp4server v0.0.0-20181031114812-7d4a0a7f59a5
# [1] git ls-remote https://github.com/d2g/dhcp4server 7d4a0a7f59a572d629ba5f49634b35c7fac7967e 
SRCREV_dhcp4server="7d4a0a7f59a572d629ba5f49634b35c7fac7967e"
SRC_URI += "git://github.com/d2g/dhcp4server;name=dhcp4server;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/d2g/dhcp4server"

# github.com/d2g/hardwareaddr v0.0.0-20190221164911-e7d9fbe030e4
# [1] git ls-remote https://github.com/d2g/hardwareaddr e7d9fbe030e4b7b08e3bdd128e2e81809e4389fd 
SRCREV_hardwareaddr="e7d9fbe030e4b7b08e3bdd128e2e81809e4389fd"
SRC_URI += "git://github.com/d2g/hardwareaddr;name=hardwareaddr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/d2g/hardwareaddr"

# github.com/danieljoos/wincred v1.1.0
# [1] git ls-remote https://github.com/danieljoos/wincred 78f93c1f8b99b0c2f6e7f3d2bdc4993cf87bddff 
SRCREV_wincred="78f93c1f8b99b0c2f6e7f3d2bdc4993cf87bddff"
SRC_URI += "git://github.com/danieljoos/wincred;name=wincred;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/danieljoos/wincred"

# github.com/davecgh/go-spew v1.1.1
# [1] git ls-remote https://github.com/davecgh/go-spew 152484fe5c9ff65d013f0f372d748c03e8749e6d 
SRCREV_go-spew="152484fe5c9ff65d013f0f372d748c03e8749e6d"
SRC_URI += "git://github.com/davecgh/go-spew;name=go-spew;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/davecgh/go-spew"

# github.com/daviddengcn/go-colortext v0.0.0-20160507010035-511bcaf42ccd
# [1] git ls-remote https://github.com/daviddengcn/go-colortext 511bcaf42ccd42c38aba7427b6673277bf19e2a1 
SRCREV_go-colortext="511bcaf42ccd42c38aba7427b6673277bf19e2a1"
SRC_URI += "git://github.com/daviddengcn/go-colortext;name=go-colortext;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/daviddengcn/go-colortext"

# github.com/denverdino/aliyungo v0.0.0-20190125010748-a747050bb1ba
# [1] git ls-remote https://github.com/denverdino/aliyungo a747050bb1baf06cdd65de7cddc281a2b1c2fde5 
SRCREV_aliyungo="a747050bb1baf06cdd65de7cddc281a2b1c2fde5"
SRC_URI += "git://github.com/denverdino/aliyungo;name=aliyungo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/denverdino/aliyungo"

# github.com/dgrijalva/jwt-go v3.2.0+incompatible
# [1] git ls-remote https://github.com/dgrijalva/jwt-go 06ea1031745cb8b3dab3f6a236daf2b0aa468b7e 
SRCREV_jwt-go="06ea1031745cb8b3dab3f6a236daf2b0aa468b7e"
SRC_URI += "git://github.com/dgrijalva/jwt-go;name=jwt-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/dgrijalva/jwt-go"

# github.com/dgryski/go-farm v0.0.0-20171119141306-ac7624ea8da3
# [1] git ls-remote https://github.com/dgryski/go-farm ac7624ea8da311f2fbbd94401d8c1cf66089f9fb 
SRCREV_go-farm="ac7624ea8da311f2fbbd94401d8c1cf66089f9fb"
SRC_URI += "git://github.com/dgryski/go-farm;name=go-farm;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/dgryski/go-farm"

# github.com/dgryski/go-sip13 v0.0.0-20181026042036-e10d5fee7954
# [1] git ls-remote https://github.com/dgryski/go-sip13 e10d5fee79544bd84105c9329adcc7b745fd588c 
SRCREV_go-sip13="e10d5fee79544bd84105c9329adcc7b745fd588c"
SRC_URI += "git://github.com/dgryski/go-sip13;name=go-sip13;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/dgryski/go-sip13"

# github.com/dnaeon/go-vcr v1.0.1
# [1] git ls-remote https://github.com/dnaeon/go-vcr 871b30b48ead17b28817bfec6226c77671f9f79a 
SRCREV_go-vcr="871b30b48ead17b28817bfec6226c77671f9f79a"
SRC_URI += "git://github.com/dnaeon/go-vcr;name=go-vcr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/dnaeon/go-vcr"

# github.com/docker/cli v20.10.10+incompatible
# [1] git ls-remote https://github.com/docker/cli ec1e6b3fce53a421de65d7da46501d7806bf83c3 
SRCREV_cli="ec1e6b3fce53a421de65d7da46501d7806bf83c3"
SRC_URI += "git://github.com/docker/cli;name=cli;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/cli"

# github.com/docker/distribution v2.7.1+incompatible
# [1] git ls-remote https://github.com/docker/distribution ea7032ddc60c872197a0f57e49319bb6092548fe 
SRCREV_distribution="ea7032ddc60c872197a0f57e49319bb6092548fe"
SRC_URI += "git://github.com/docker/distribution;name=distribution;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/distribution"

# github.com/docker/docker v20.10.2+incompatible
# [1] git ls-remote https://github.com/docker/docker 298bd21ab4670e06b188ef179302c84bc59f193e 
SRCREV_docker="298bd21ab4670e06b188ef179302c84bc59f193e"
SRC_URI += "git://github.com/docker/docker;name=docker;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/docker"

# github.com/docker/docker-credential-helpers v0.6.4
# [1] git ls-remote https://github.com/docker/docker-credential-helpers fc9290adbcf1594e78910e2f0334090eaee0e1ee 
SRCREV_docker-credential-helpers="fc9290adbcf1594e78910e2f0334090eaee0e1ee"
SRC_URI += "git://github.com/docker/docker-credential-helpers;name=docker-credential-helpers;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/docker-credential-helpers"

# github.com/docker/go-connections v0.4.0
# [1] git ls-remote https://github.com/docker/go-connections 7395e3f8aa162843a74ed6d48e79627d9792ac55 
SRCREV_go-connections="7395e3f8aa162843a74ed6d48e79627d9792ac55"
SRC_URI += "git://github.com/docker/go-connections;name=go-connections;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-connections"

# github.com/docker/go-events v0.0.0-20190806004212-e31b211e4f1c
# [1] git ls-remote https://github.com/docker/go-events e31b211e4f1cd09aa76fe4ac244571fab96ae47f 
SRCREV_go-events="e31b211e4f1cd09aa76fe4ac244571fab96ae47f"
SRC_URI += "git://github.com/docker/go-events;name=go-events;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-events"

# github.com/docker/go-metrics v0.0.1
# [1] git ls-remote https://github.com/docker/go-metrics b619b3592b65de4f087d9f16863a7e6ff905973c 
SRCREV_go-metrics1="b619b3592b65de4f087d9f16863a7e6ff905973c"
SRC_URI += "git://github.com/docker/go-metrics;name=go-metrics1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-metrics"

# github.com/docker/go-units v0.4.0
# [1] git ls-remote https://github.com/docker/go-units 62a2352f021aa740f52d67afa00d211290c5855c 
SRCREV_go-units="62a2352f021aa740f52d67afa00d211290c5855c"
SRC_URI += "git://github.com/docker/go-units;name=go-units;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docker/go-units"

# github.com/docopt/docopt-go v0.0.0-20180111231733-ee0de3bc6815
# [1] git ls-remote https://github.com/docopt/docopt-go ee0de3bc6815ee19d4a46c7eb90f829db0e014b1 
SRCREV_docopt-go="ee0de3bc6815ee19d4a46c7eb90f829db0e014b1"
SRC_URI += "git://github.com/docopt/docopt-go;name=docopt-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/docopt/docopt-go"

# github.com/dustin/go-humanize v1.0.0
# [1] git ls-remote https://github.com/dustin/go-humanize e673fa1ffc91213297a60d18a6f513aa74bced52 
SRCREV_go-humanize="e673fa1ffc91213297a60d18a6f513aa74bced52"
SRC_URI += "git://github.com/dustin/go-humanize;name=go-humanize;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/dustin/go-humanize"

# github.com/dustmop/soup v1.1.2-0.20190516214245-38228baa104e
# [1] git ls-remote https://github.com/dustmop/soup 38228baa104ea9c9b73420407c1c4ba813deeaae 
SRCREV_soup="38228baa104ea9c9b73420407c1c4ba813deeaae"
SRC_URI += "git://github.com/dustmop/soup;name=soup;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/dustmop/soup"

# github.com/eapache/channels v1.1.0
# [1] git ls-remote https://github.com/eapache/channels 47238d5aae8c0fefd518ef2bee46290909cf8263 
SRCREV_channels="47238d5aae8c0fefd518ef2bee46290909cf8263"
SRC_URI += "git://github.com/eapache/channels;name=channels;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/eapache/channels"

# github.com/eapache/queue v1.1.0
# [1] git ls-remote https://github.com/eapache/queue 44cc805cf13205b55f69e14bcb69867d1ae92f98 
SRCREV_queue="44cc805cf13205b55f69e14bcb69867d1ae92f98"
SRC_URI += "git://github.com/eapache/queue;name=queue;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/eapache/queue"

# github.com/elazarl/goproxy v0.0.0-20180725130230-947c36da3153
# [1] git ls-remote https://github.com/elazarl/goproxy 947c36da3153ff334e74d9d980de341d25f358ba 
SRCREV_goproxy="947c36da3153ff334e74d9d980de341d25f358ba"
SRC_URI += "git://github.com/elazarl/goproxy;name=goproxy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/elazarl/goproxy"

# github.com/emicklei/go-restful v2.9.5+incompatible
# [1] git ls-remote https://github.com/emicklei/go-restful 3e6bdb66f81150bda4be5cc1c3a79fc4b1cf00f9 
SRCREV_go-restful="3e6bdb66f81150bda4be5cc1c3a79fc4b1cf00f9"
SRC_URI += "git://github.com/emicklei/go-restful;name=go-restful;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/emicklei/go-restful"

# github.com/envoyproxy/go-control-plane v0.9.9-0.20210217033140-668b12f5399d
# [1] git ls-remote https://github.com/envoyproxy/go-control-plane 668b12f5399deff9d7a31ecfcf413182a31574c0 
SRCREV_go-control-plane="668b12f5399deff9d7a31ecfcf413182a31574c0"
SRC_URI += "git://github.com/envoyproxy/go-control-plane;name=go-control-plane;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/envoyproxy/go-control-plane"

# github.com/envoyproxy/protoc-gen-validate v0.1.0
# [1] git ls-remote https://github.com/envoyproxy/protoc-gen-validate b894e268e4263489751edd651656a98572ffc718 
SRCREV_protoc-gen-validate="b894e268e4263489751edd651656a98572ffc718"
SRC_URI += "git://github.com/envoyproxy/protoc-gen-validate;name=protoc-gen-validate;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/envoyproxy/protoc-gen-validate"

# github.com/erikdubbelboer/gspt v0.0.0-20190125194910-e68493906b83
# [1] git ls-remote https://github.com/erikdubbelboer/gspt e68493906b8382891943ddc9960cb9c6ecd1a1f0 
SRCREV_gspt="e68493906b8382891943ddc9960cb9c6ecd1a1f0"
SRC_URI += "git://github.com/erikdubbelboer/gspt;name=gspt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/erikdubbelboer/gspt"

# github.com/euank/go-kmsg-parser v2.0.0+incompatible
# [1] git ls-remote https://github.com/euank/go-kmsg-parser 5ba4d492e455a77d25dcf0d2c4acc9f2afebef4e 
SRCREV_go-kmsg-parser="5ba4d492e455a77d25dcf0d2c4acc9f2afebef4e"
SRC_URI += "git://github.com/euank/go-kmsg-parser;name=go-kmsg-parser;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/euank/go-kmsg-parser"

# github.com/evanphx/json-patch v4.11.0+incompatible
# [1] git ls-remote https://github.com/evanphx/json-patch 3c3c85ec60c9921ef01901c824e95a6b0a4e45d1 
SRCREV_json-patch="3c3c85ec60c9921ef01901c824e95a6b0a4e45d1"
SRC_URI += "git://github.com/evanphx/json-patch;name=json-patch;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/evanphx/json-patch"

# github.com/exponent-io/jsonpath v0.0.0-20151013193312-d6023ce2651d
# [1] git ls-remote https://github.com/exponent-io/jsonpath d6023ce2651d8eafb5c75bb0c7167536102ec9f5 
SRCREV_jsonpath="d6023ce2651d8eafb5c75bb0c7167536102ec9f5"
SRC_URI += "git://github.com/exponent-io/jsonpath;name=jsonpath;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/exponent-io/jsonpath"

# github.com/fanliao/go-promise v0.0.0-20141029170127-1890db352a72
# [1] git ls-remote https://github.com/fanliao/go-promise 1890db352a72f9e6c6219c20111355cddc795297 
SRCREV_go-promise="1890db352a72f9e6c6219c20111355cddc795297"
SRC_URI += "git://github.com/fanliao/go-promise;name=go-promise;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fanliao/go-promise"

# github.com/fatih/camelcase v1.0.0
# [1] git ls-remote https://github.com/fatih/camelcase 44e46d280b43ec1531bb25252440e34f1b800b65 
SRCREV_camelcase="44e46d280b43ec1531bb25252440e34f1b800b65"
SRC_URI += "git://github.com/fatih/camelcase;name=camelcase;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fatih/camelcase"

# github.com/fatih/color v1.9.0
# [1] git ls-remote https://github.com/fatih/color daf2830f2741ebb735b21709a520c5f37d642d85 
SRCREV_color="daf2830f2741ebb735b21709a520c5f37d642d85"
SRC_URI += "git://github.com/fatih/color;name=color;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fatih/color"

# github.com/felixge/httpsnoop v1.0.1
# [1] git ls-remote https://github.com/felixge/httpsnoop 33ec42cfe005395fb4cc4b296781f65d7ffef2c3 
SRCREV_httpsnoop="33ec42cfe005395fb4cc4b296781f65d7ffef2c3"
SRC_URI += "git://github.com/felixge/httpsnoop;name=httpsnoop;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/felixge/httpsnoop"

# github.com/flannel-io/flannel v0.16.3
# [1] git ls-remote https://github.com/flannel-io/flannel aba86a5775f9ce103a3fc5958da3e31dafd5cf50 
SRCREV_flannel="aba86a5775f9ce103a3fc5958da3e31dafd5cf50"
SRC_URI += "git://github.com/flannel-io/flannel;name=flannel;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/flannel-io/flannel"

# github.com/flynn/go-shlex v0.0.0-20150515145356-3f9db97f8568
# [1] git ls-remote https://github.com/flynn/go-shlex 3f9db97f856818214da2e1057f8ad84803971cff 
SRCREV_go-shlex="3f9db97f856818214da2e1057f8ad84803971cff"
SRC_URI += "git://github.com/flynn/go-shlex;name=go-shlex;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/flynn/go-shlex"

# github.com/fogleman/gg v1.2.1-0.20190220221249-0403632d5b90
# [1] git ls-remote https://github.com/fogleman/gg 0403632d5b905943a1c2a5b2763aaecd568467ec 
SRCREV_gg="0403632d5b905943a1c2a5b2763aaecd568467ec"
SRC_URI += "git://github.com/fogleman/gg;name=gg;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fogleman/gg"

# github.com/form3tech-oss/jwt-go v3.2.3+incompatible
# [1] git ls-remote https://github.com/form3tech-oss/jwt-go 5b2d2b5f6c34ccb3b6b65f77f4706558067690ef 
SRCREV_jwt-go1="5b2d2b5f6c34ccb3b6b65f77f4706558067690ef"
SRC_URI += "git://github.com/form3tech-oss/jwt-go;name=jwt-go1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/form3tech-oss/jwt-go"

# github.com/frankban/quicktest v1.12.1
# [1] git ls-remote https://github.com/frankban/quicktest 46a4d984dc347eaa97966c8cc7b5630c2c1d3105 
SRCREV_quicktest="46a4d984dc347eaa97966c8cc7b5630c2c1d3105"
SRC_URI += "git://github.com/frankban/quicktest;name=quicktest;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/frankban/quicktest"

# github.com/fsnotify/fsnotify v1.4.9
# [1] git ls-remote https://github.com/fsnotify/fsnotify 45d7d09e39ef4ac08d493309fa031790c15bfe8a 
SRCREV_fsnotify="45d7d09e39ef4ac08d493309fa031790c15bfe8a"
SRC_URI += "git://github.com/fsnotify/fsnotify;name=fsnotify;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fsnotify/fsnotify"

# github.com/fvbommel/sortorder v1.0.1
# [1] git ls-remote https://github.com/fvbommel/sortorder a1ddee917217bbd0691affdca9c88d24d3f5c27d 
SRCREV_sortorder="a1ddee917217bbd0691affdca9c88d24d3f5c27d"
SRC_URI += "git://github.com/fvbommel/sortorder;name=sortorder;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/fvbommel/sortorder"

# github.com/getsentry/raven-go v0.2.0
# [1] git ls-remote https://github.com/getsentry/raven-go f04e7487e9a6b9d9837d52743fb5f40576c56411 
SRCREV_raven-go="f04e7487e9a6b9d9837d52743fb5f40576c56411"
SRC_URI += "git://github.com/getsentry/raven-go;name=raven-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/getsentry/raven-go"

# github.com/ghodss/yaml v1.0.0
# [1] git ls-remote https://github.com/ghodss/yaml 0ca9ea5df5451ffdf184b4428c902747c2c11cd7 
SRCREV_yaml="0ca9ea5df5451ffdf184b4428c902747c2c11cd7"
SRC_URI += "git://github.com/ghodss/yaml;name=yaml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ghodss/yaml"

# github.com/globalsign/mgo v0.0.0-20181015135952-eeefdecb41b8
# [1] git ls-remote https://github.com/globalsign/mgo eeefdecb41b842af6dc652aaea4026e8403e62df 
SRCREV_mgo="eeefdecb41b842af6dc652aaea4026e8403e62df"
SRC_URI += "git://github.com/globalsign/mgo;name=mgo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/globalsign/mgo"

# github.com/go-bindata/go-bindata v3.1.2+incompatible
# [1] git ls-remote https://github.com/go-bindata/go-bindata ff7109080027ec152dabb369e157c4f359b76f31 
SRCREV_go-bindata="ff7109080027ec152dabb369e157c4f359b76f31"
SRC_URI += "git://github.com/go-bindata/go-bindata;name=go-bindata;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-bindata/go-bindata"

# github.com/go-errors/errors v1.0.1
# [1] git ls-remote https://github.com/go-errors/errors a6af135bd4e28680facf08a3d206b454abc877a4 
SRCREV_errors1="a6af135bd4e28680facf08a3d206b454abc877a4"
SRC_URI += "git://github.com/go-errors/errors;name=errors1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-errors/errors"

# github.com/go-gl/glfw v0.0.0-20190409004039-e6da0acd62b1
# [1] git ls-remote https://github.com/go-gl/glfw e6da0acd62b1b57ee2799d4d0a76a7d4514dc5bc 
SRCREV_glfw="e6da0acd62b1b57ee2799d4d0a76a7d4514dc5bc"
SRC_URI += "git://github.com/go-gl/glfw;name=glfw;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-gl/glfw"

# github.com/go-gl/glfw/v3.3/glfw v0.0.0-20200222043503-6f7a984d4dc4
# [1] git ls-remote https://github.com/go-gl/glfw 6f7a984d4dc470c3f197229ad1991ae9e211bba2 
SRCREV_glfw1="6f7a984d4dc470c3f197229ad1991ae9e211bba2"
SRC_URI += "git://github.com/go-gl/glfw;name=glfw1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-gl/glfw/v3.3/glfw"

# github.com/go-ini/ini v1.28.1
# [1] git ls-remote https://github.com/go-ini/ini 3d73f4b845efdf9989fffd4b4e562727744a34ba 
SRCREV_ini="3d73f4b845efdf9989fffd4b4e562727744a34ba"
SRC_URI += "git://github.com/go-ini/ini;name=ini;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-ini/ini"

# github.com/go-kit/kit v0.9.0
# [1] git ls-remote https://github.com/go-kit/kit 150a65a7ec6156b4b640c1fd55f26fd3d475d656 
SRCREV_kit="150a65a7ec6156b4b640c1fd55f26fd3d475d656"
SRC_URI += "git://github.com/go-kit/kit;name=kit;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-kit/kit"

# github.com/go-kit/log v0.1.0
# [1] git ls-remote https://github.com/go-kit/log 63376a29a92260f7b256eedf2fae39e28161114d 
SRCREV_log="63376a29a92260f7b256eedf2fae39e28161114d"
SRC_URI += "git://github.com/go-kit/log;name=log;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-kit/log"

# github.com/go-logfmt/logfmt v0.5.0
# [1] git ls-remote https://github.com/go-logfmt/logfmt 7afbabc575def289dded38dc182d1ca197bbfa22 
SRCREV_logfmt="7afbabc575def289dded38dc182d1ca197bbfa22"
SRC_URI += "git://github.com/go-logfmt/logfmt;name=logfmt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-logfmt/logfmt"

# github.com/go-logr/logr v0.4.0
# [1] git ls-remote https://github.com/go-logr/logr 8fc6c73f3911f11de3d0c18ade9880f1114ae72f 
SRCREV_logr="8fc6c73f3911f11de3d0c18ade9880f1114ae72f"
SRC_URI += "git://github.com/go-logr/logr;name=logr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-logr/logr"

# github.com/go-logr/zapr v0.1.0
# [1] git ls-remote https://github.com/go-logr/zapr 7536572e8d55209135cd5e7ccf7fce43dca217ab 
SRCREV_zapr="7536572e8d55209135cd5e7ccf7fce43dca217ab"
SRC_URI += "git://github.com/go-logr/zapr;name=zapr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-logr/zapr"

# github.com/go-openapi/analysis v0.19.5
# [1] git ls-remote https://github.com/go-openapi/analysis 6f70729e6857d3987b435a501dd69beaa8bcb1bc 
SRCREV_analysis="6f70729e6857d3987b435a501dd69beaa8bcb1bc"
SRC_URI += "git://github.com/go-openapi/analysis;name=analysis;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/analysis"

# github.com/go-openapi/errors v0.19.2
# [1] git ls-remote https://github.com/go-openapi/errors 0a120edb04c2d2235ff2f7c898ad6178809ea39d 
SRCREV_errors12="0a120edb04c2d2235ff2f7c898ad6178809ea39d"
SRC_URI += "git://github.com/go-openapi/errors;name=errors12;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/errors"

# github.com/go-openapi/jsonpointer v0.19.5
# [1] git ls-remote https://github.com/go-openapi/jsonpointer a48280f97959fc230ba72550e0a7e7e49d321e1d 
SRCREV_jsonpointer="a48280f97959fc230ba72550e0a7e7e49d321e1d"
SRC_URI += "git://github.com/go-openapi/jsonpointer;name=jsonpointer;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/jsonpointer"

# github.com/go-openapi/jsonreference v0.19.5
# [1] git ls-remote https://github.com/go-openapi/jsonreference 28a8ff900147568dc266d4cd84e062750e44f161 
SRCREV_jsonreference="28a8ff900147568dc266d4cd84e062750e44f161"
SRC_URI += "git://github.com/go-openapi/jsonreference;name=jsonreference;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/jsonreference"

# github.com/go-openapi/loads v0.19.4
# [1] git ls-remote https://github.com/go-openapi/loads 08a83097cc08312bd7e0e41dd19fee4e908232df 
SRCREV_loads="08a83097cc08312bd7e0e41dd19fee4e908232df"
SRC_URI += "git://github.com/go-openapi/loads;name=loads;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/loads"

# github.com/go-openapi/runtime v0.19.4
# [1] git ls-remote https://github.com/go-openapi/runtime 2a4238f8bbfd6a60d7c7ed67d050cdbe364aebac 
SRCREV_runtime="2a4238f8bbfd6a60d7c7ed67d050cdbe364aebac"
SRC_URI += "git://github.com/go-openapi/runtime;name=runtime;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/runtime"

# github.com/go-openapi/spec v0.19.5
# [1] git ls-remote https://github.com/go-openapi/spec 49edd8e9ef3c84b99d565f5e3b9f7d5d27659b2c 
SRCREV_spec1="49edd8e9ef3c84b99d565f5e3b9f7d5d27659b2c"
SRC_URI += "git://github.com/go-openapi/spec;name=spec1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/spec"

# github.com/go-openapi/strfmt v0.19.5
# [1] git ls-remote https://github.com/go-openapi/strfmt 5bbd8bd13d7cc830fc92dfdb6c2cb4054e389bea 
SRCREV_strfmt="5bbd8bd13d7cc830fc92dfdb6c2cb4054e389bea"
SRC_URI += "git://github.com/go-openapi/strfmt;name=strfmt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/strfmt"

# github.com/go-openapi/swag v0.19.14
# [1] git ls-remote https://github.com/go-openapi/swag c78fa6719bc3d4b977d19a09064feda1c07571af 
SRCREV_swag="c78fa6719bc3d4b977d19a09064feda1c07571af"
SRC_URI += "git://github.com/go-openapi/swag;name=swag;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/swag"

# github.com/go-openapi/validate v0.19.8
# [1] git ls-remote https://github.com/go-openapi/validate e3f5ffaa902f65cef388cdef8a7fc9fdd618d18f 
SRCREV_validate="e3f5ffaa902f65cef388cdef8a7fc9fdd618d18f"
SRC_URI += "git://github.com/go-openapi/validate;name=validate;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-openapi/validate"

# github.com/go-ozzo/ozzo-validation v3.5.0+incompatible
# [1] git ls-remote https://github.com/go-ozzo/ozzo-validation 106681dbb37bfa3e7683c4c8129cb7f5925ea3e9 
SRCREV_ozzo-validation="106681dbb37bfa3e7683c4c8129cb7f5925ea3e9"
SRC_URI += "git://github.com/go-ozzo/ozzo-validation;name=ozzo-validation;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-ozzo/ozzo-validation"

# github.com/go-sql-driver/mysql v1.6.0
# [1] git ls-remote https://github.com/go-sql-driver/mysql bcc459a906419e2890a50fc2c99ea6dd927a88f2 
SRCREV_mysql="bcc459a906419e2890a50fc2c99ea6dd927a88f2"
SRC_URI += "git://github.com/go-sql-driver/mysql;name=mysql;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-sql-driver/mysql"

# github.com/go-stack/stack v1.8.0
# [1] git ls-remote https://github.com/go-stack/stack f66e05c21cd224e01c8a3ee7bc867aa79439e207 
SRCREV_stack="f66e05c21cd224e01c8a3ee7bc867aa79439e207"
SRC_URI += "git://github.com/go-stack/stack;name=stack;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-stack/stack"

# github.com/go-task/slim-sprig v0.0.0-20210107165309-348f09dbbbc0
# [1] git ls-remote https://github.com/go-task/slim-sprig 348f09dbbbc0ff8b922a311da7a90cd014b69aa3 
SRCREV_slim-sprig="348f09dbbbc0ff8b922a311da7a90cd014b69aa3"
SRC_URI += "git://github.com/go-task/slim-sprig;name=slim-sprig;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-task/slim-sprig"

# github.com/go-test/deep v1.0.6
# [1] git ls-remote https://github.com/go-test/deep 17394cbf6bf88945e8ffab0f084ab409167b5ed2 
SRCREV_deep="17394cbf6bf88945e8ffab0f084ab409167b5ed2"
SRC_URI += "git://github.com/go-test/deep;name=deep;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/go-test/deep"

# github.com/goccy/go-json v0.7.10
# [1] git ls-remote https://github.com/goccy/go-json a89c9e30df2502328afc391b8b17931c706babad 
SRCREV_go-json="a89c9e30df2502328afc391b8b17931c706babad"
SRC_URI += "git://github.com/goccy/go-json;name=go-json;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/goccy/go-json"

# github.com/godbus/dbus v0.0.0-20180201030542-885f9cc04c9c
# [1] git ls-remote https://github.com/godbus/dbus 885f9cc04c9c1a6a61a2008e211d36c5737be3f5 
SRCREV_dbus="885f9cc04c9c1a6a61a2008e211d36c5737be3f5"
SRC_URI += "git://github.com/godbus/dbus;name=dbus;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/godbus/dbus"

# github.com/godbus/dbus/v5 v5.0.4
# [1] git ls-remote https://github.com/godbus/dbus c88335c0b1d28a30e7fc76d526a06154b85e5d97 
SRCREV_v51="c88335c0b1d28a30e7fc76d526a06154b85e5d97"
SRC_URI += "git://github.com/godbus/dbus;name=v51;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/godbus/dbus/v5"

# github.com/gofrs/flock v0.8.1
# [1] git ls-remote https://github.com/gofrs/flock a14e9f39bdc9c4be4c0ccddb25b72bbc9670c429 
SRCREV_flock="a14e9f39bdc9c4be4c0ccddb25b72bbc9670c429"
SRC_URI += "git://github.com/gofrs/flock;name=flock;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gofrs/flock"

# github.com/gofrs/uuid v4.0.0+incompatible
# [1] git ls-remote https://github.com/gofrs/uuid 4b36aa0ea796d49630bbae624f8f05ab7013af77 
SRCREV_uuid="4b36aa0ea796d49630bbae624f8f05ab7013af77"
SRC_URI += "git://github.com/gofrs/uuid;name=uuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gofrs/uuid"

# github.com/gogo/googleapis v1.4.0
# [1] git ls-remote https://github.com/gogo/googleapis 3a822044bc0ae0a330a7449d52de760218351d49 
SRCREV_googleapis="3a822044bc0ae0a330a7449d52de760218351d49"
SRC_URI += "git://github.com/gogo/googleapis;name=googleapis;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gogo/googleapis"

# github.com/gogo/protobuf v1.3.2
# [1] git ls-remote https://github.com/gogo/protobuf b03c65ea87cdc3521ede29f62fe3ce239267c1bc 
SRCREV_protobuf="b03c65ea87cdc3521ede29f62fe3ce239267c1bc"
SRC_URI += "git://github.com/gogo/protobuf;name=protobuf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gogo/protobuf"

# github.com/golang/freetype v0.0.0-20170609003504-e2365dfdc4a0
# [1] git ls-remote https://github.com/golang/freetype e2365dfdc4a05e4b8299a783240d4a7d5a65d4e4 
SRCREV_freetype="e2365dfdc4a05e4b8299a783240d4a7d5a65d4e4"
SRC_URI += "git://github.com/golang/freetype;name=freetype;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/freetype"

# github.com/golang/glog v0.0.0-20160126235308-23def4e6c14b
# [1] git ls-remote https://github.com/golang/glog 23def4e6c14b4da8ac2ed8007337bc5eb5007998 
SRCREV_glog="23def4e6c14b4da8ac2ed8007337bc5eb5007998"
SRC_URI += "git://github.com/golang/glog;name=glog;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/glog"

# github.com/golang/groupcache v0.0.0-20210331224755-41bb18bfe9da
# [1] git ls-remote https://github.com/golang/groupcache 41bb18bfe9da5321badc438f91158cd790a33aa3 
SRCREV_groupcache="41bb18bfe9da5321badc438f91158cd790a33aa3"
SRC_URI += "git://github.com/golang/groupcache;name=groupcache;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/groupcache"

# github.com/golang/mock v1.6.0
# [1] git ls-remote https://github.com/golang/mock aba2ff9a6844d5e3289e8472d3217d5b3090f083 
SRCREV_mock="aba2ff9a6844d5e3289e8472d3217d5b3090f083"
SRC_URI += "git://github.com/golang/mock;name=mock;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/mock"

# github.com/golang/protobuf v1.5.2
# [1] git ls-remote https://github.com/golang/protobuf ae97035608a719c7a1c1c41bed0ae0744bdb0c6f 
SRCREV_protobuf1="ae97035608a719c7a1c1c41bed0ae0744bdb0c6f"
SRC_URI += "git://github.com/golang/protobuf;name=protobuf1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/protobuf"

# github.com/golang/snappy v0.0.3
# [1] git ls-remote https://github.com/golang/snappy 674baa8c7fc30da5df3074a459494a7e6b427dff 
SRCREV_snappy="674baa8c7fc30da5df3074a459494a7e6b427dff"
SRC_URI += "git://github.com/golang/snappy;name=snappy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golang/snappy"

# github.com/golangplus/bytes v0.0.0-20160111154220-45c989fe5450
# [1] git ls-remote https://github.com/golangplus/bytes 45c989fe545070ef7c9003cf1998bb195c61731a 
SRCREV_bytes="45c989fe545070ef7c9003cf1998bb195c61731a"
SRC_URI += "git://github.com/golangplus/bytes;name=bytes;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golangplus/bytes"

# github.com/golangplus/fmt v1.0.0
# [1] git ls-remote https://github.com/golangplus/fmt 7a904709ad79c030bc913f5d1d1823dcf3953fa4 
SRCREV_fmt="7a904709ad79c030bc913f5d1d1823dcf3953fa4"
SRC_URI += "git://github.com/golangplus/fmt;name=fmt;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golangplus/fmt"

# github.com/golangplus/testing v1.0.0
# [1] git ls-remote https://github.com/golangplus/testing d51138b619a0cd6d297e1a9985accd95ca75be46 
SRCREV_testing="d51138b619a0cd6d297e1a9985accd95ca75be46"
SRC_URI += "git://github.com/golangplus/testing;name=testing;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/golangplus/testing"

# github.com/google/btree v1.0.1
# [1] git ls-remote https://github.com/google/btree 479b5e81b0a93ec038d201b0b33d17db599531d3 
SRCREV_btree="479b5e81b0a93ec038d201b0b33d17db599531d3"
SRC_URI += "git://github.com/google/btree;name=btree;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/btree"

# github.com/google/cadvisor v0.39.3
# [1] git ls-remote https://github.com/google/cadvisor 624ab2ff8a1ec94ceae3a4aac109eceffeed0444 
SRCREV_cadvisor="624ab2ff8a1ec94ceae3a4aac109eceffeed0444"
SRC_URI += "git://github.com/google/cadvisor;name=cadvisor;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/cadvisor"

# github.com/google/go-cmp v0.5.6
# [1] git ls-remote https://github.com/google/go-cmp d103655696d8ae43c4125ee61454dbf03d8e8324 
SRCREV_go-cmp="d103655696d8ae43c4125ee61454dbf03d8e8324"
SRC_URI += "git://github.com/google/go-cmp;name=go-cmp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/go-cmp"

# github.com/google/go-containerregistry v0.6.1-0.20211111182346-7a6ee45528a9
# [1] git ls-remote https://github.com/google/go-containerregistry 7a6ee45528a9faed11cf55b539478bd81d439868 
SRCREV_go-containerregistry="7a6ee45528a9faed11cf55b539478bd81d439868"
SRC_URI += "git://github.com/google/go-containerregistry;name=go-containerregistry;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/go-containerregistry"

# github.com/google/gofuzz v1.1.0
# [1] git ls-remote https://github.com/google/gofuzz db92cf7ae75e4a7a28abc005addab2b394362888 
SRCREV_gofuzz="db92cf7ae75e4a7a28abc005addab2b394362888"
SRC_URI += "git://github.com/google/gofuzz;name=gofuzz;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/gofuzz"

# github.com/google/martian v2.1.0+incompatible
# [1] git ls-remote https://github.com/google/martian 195b986b4b6d4c513582cf4d2b8c4fd7e2494f7e 
SRCREV_martian="195b986b4b6d4c513582cf4d2b8c4fd7e2494f7e"
SRC_URI += "git://github.com/google/martian;name=martian;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/martian"

# github.com/google/martian/v3 v3.2.1
# [1] git ls-remote https://github.com/google/martian 7e75073889cd2324f33b959c4fb4545440da046c 
SRCREV_v3="7e75073889cd2324f33b959c4fb4545440da046c"
SRC_URI += "git://github.com/google/martian;name=v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/martian/v3"

# github.com/google/pprof v0.0.0-20210720184732-4bb14d4b1be1
# [1] git ls-remote https://github.com/google/pprof 4bb14d4b1be14417e47d0bbaf2bd4e188eda647f 
SRCREV_pprof="4bb14d4b1be14417e47d0bbaf2bd4e188eda647f"
SRC_URI += "git://github.com/google/pprof;name=pprof;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/pprof"

# github.com/google/renameio v0.1.0
# [1] git ls-remote https://github.com/google/renameio f0e32980c006571efd537032e5f9cd8c1a92819e 
SRCREV_renameio="f0e32980c006571efd537032e5f9cd8c1a92819e"
SRC_URI += "git://github.com/google/renameio;name=renameio;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/renameio"

# github.com/google/shlex v0.0.0-20191202100458-e7afc7fbc510
# [1] git ls-remote https://github.com/google/shlex e7afc7fbc51079733e9468cdfd1efcd7d196cd1d 
SRCREV_shlex="e7afc7fbc51079733e9468cdfd1efcd7d196cd1d"
SRC_URI += "git://github.com/google/shlex;name=shlex;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/shlex"

# github.com/google/uuid v1.3.0
# [1] git ls-remote https://github.com/google/uuid 44b5fee7c49cf3bcdf723f106b36d56ef13ccc88 
SRCREV_uuid1="44b5fee7c49cf3bcdf723f106b36d56ef13ccc88"
SRC_URI += "git://github.com/google/uuid;name=uuid1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/uuid"

# github.com/googleapis/gax-go/v2 v2.0.5
# [1] git ls-remote https://github.com/googleapis/gax-go bd5b16380fd03dc758d11cef74ba2e3bc8b0e8c2 
SRCREV_v212="bd5b16380fd03dc758d11cef74ba2e3bc8b0e8c2"
SRC_URI += "git://github.com/googleapis/gax-go;name=v212;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/googleapis/gax-go/v2"

# github.com/googleapis/gnostic v0.5.5
# [1] git ls-remote https://github.com/googleapis/gnostic 1550ae29653d42db69c8a98d368648be7f2c488d 
SRCREV_gnostic="1550ae29653d42db69c8a98d368648be7f2c488d"
SRC_URI += "git://github.com/googleapis/gnostic;name=gnostic;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/googleapis/gnostic"

# github.com/gophercloud/gophercloud v0.1.0
# [1] git ls-remote https://github.com/gophercloud/gophercloud c2d73b246b48e239d3f03c455905e06fe26e33c3 
SRCREV_gophercloud="c2d73b246b48e239d3f03c455905e06fe26e33c3"
SRC_URI += "git://github.com/gophercloud/gophercloud;name=gophercloud;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gophercloud/gophercloud"

# github.com/gopherjs/gopherjs v0.0.0-20200217142428-fce0ec30dd00
# [1] git ls-remote https://github.com/gopherjs/gopherjs fce0ec30dd00773d3fa974351d04ce2737b5c4d9 
SRCREV_gopherjs="fce0ec30dd00773d3fa974351d04ce2737b5c4d9"
SRC_URI += "git://github.com/gopherjs/gopherjs;name=gopherjs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gopherjs/gopherjs"

# github.com/gorilla/mux v1.8.0
# [1] git ls-remote https://github.com/gorilla/mux 98cb6bf42e086f6af920b965c38cacc07402d51b 
SRCREV_mux="98cb6bf42e086f6af920b965c38cacc07402d51b"
SRC_URI += "git://github.com/gorilla/mux;name=mux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gorilla/mux"

# github.com/gorilla/websocket v1.4.2
# [1] git ls-remote https://github.com/gorilla/websocket b65e62901fc1c0d968042419e74789f6af455eb9 
SRCREV_websocket="b65e62901fc1c0d968042419e74789f6af455eb9"
SRC_URI += "git://github.com/gorilla/websocket;name=websocket;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gorilla/websocket"

# github.com/gregjones/httpcache v0.0.0-20180305231024-9cad4c3443a7
# [1] git ls-remote https://github.com/gregjones/httpcache 9cad4c3443a7200dd6400aef47183728de563a38 
SRCREV_httpcache="9cad4c3443a7200dd6400aef47183728de563a38"
SRC_URI += "git://github.com/gregjones/httpcache;name=httpcache;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gregjones/httpcache"

# github.com/grpc-ecosystem/go-grpc-middleware v1.3.0
# [1] git ls-remote https://github.com/grpc-ecosystem/go-grpc-middleware df0f91b29bbbdfc3a686a7a8edbe2b9de2072fdd 
SRCREV_go-grpc-middleware="df0f91b29bbbdfc3a686a7a8edbe2b9de2072fdd"
SRC_URI += "git://github.com/grpc-ecosystem/go-grpc-middleware;name=go-grpc-middleware;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/grpc-ecosystem/go-grpc-middleware"

# github.com/grpc-ecosystem/go-grpc-prometheus v1.2.0
# [1] git ls-remote https://github.com/grpc-ecosystem/go-grpc-prometheus 502116f1a0a0c1140aab04fd3787489209b357d3 
SRCREV_go-grpc-prometheus="502116f1a0a0c1140aab04fd3787489209b357d3"
SRC_URI += "git://github.com/grpc-ecosystem/go-grpc-prometheus;name=go-grpc-prometheus;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/grpc-ecosystem/go-grpc-prometheus"

# github.com/grpc-ecosystem/grpc-gateway v1.16.0
# [1] git ls-remote https://github.com/grpc-ecosystem/grpc-gateway 094a6fe78b3ca888297d090185cdf30f0e42e157 
SRCREV_grpc-gateway="094a6fe78b3ca888297d090185cdf30f0e42e157"
SRC_URI += "git://github.com/grpc-ecosystem/grpc-gateway;name=grpc-gateway;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/grpc-ecosystem/grpc-gateway"

# github.com/hanwen/go-fuse/v2 v2.1.1-0.20210825171523-3ab5d95a30ae
# [1] git ls-remote https://github.com/hanwen/go-fuse 3ab5d95a30ae25019bf030a2bab076dba61c27da 
SRCREV_v2123="3ab5d95a30ae25019bf030a2bab076dba61c27da"
SRC_URI += "git://github.com/hanwen/go-fuse;name=v2123;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hanwen/go-fuse/v2"

# github.com/hashicorp/consul/api v1.1.0
# [1] git ls-remote https://github.com/hashicorp/consul 6ff90c3c851705f389624e034f2d0b6d816ddc61 
SRCREV_api="6ff90c3c851705f389624e034f2d0b6d816ddc61"
SRC_URI += "git://github.com/hashicorp/consul;name=api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/consul/api"

# github.com/hashicorp/consul/sdk v0.1.1
# [1] git ls-remote https://github.com/hashicorp/consul 72cdb203dc4a27a9644ecefe2ceb6e7f93337ec8 
SRCREV_sdk="72cdb203dc4a27a9644ecefe2ceb6e7f93337ec8"
SRC_URI += "git://github.com/hashicorp/consul;name=sdk;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/consul/sdk"

# github.com/hashicorp/errwrap v1.0.0
# [1] git ls-remote https://github.com/hashicorp/errwrap 8a6fb523712970c966eefc6b39ed2c5e74880354 
SRCREV_errwrap="8a6fb523712970c966eefc6b39ed2c5e74880354"
SRC_URI += "git://github.com/hashicorp/errwrap;name=errwrap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/errwrap"

# github.com/hashicorp/go-cleanhttp v0.5.1
# [1] git ls-remote https://github.com/hashicorp/go-cleanhttp eda1e5db218aad1db63ca4642c8906b26bcf2744 
SRCREV_go-cleanhttp="eda1e5db218aad1db63ca4642c8906b26bcf2744"
SRC_URI += "git://github.com/hashicorp/go-cleanhttp;name=go-cleanhttp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-cleanhttp"

# github.com/hashicorp/go-hclog v0.9.2
# [1] git ls-remote https://github.com/hashicorp/go-hclog 5ccdce08c75b6c7b37af61159f13f6a4f5e2e928 
SRCREV_go-hclog="5ccdce08c75b6c7b37af61159f13f6a4f5e2e928"
SRC_URI += "git://github.com/hashicorp/go-hclog;name=go-hclog;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-hclog"

# github.com/hashicorp/go-immutable-radix v1.0.0
# [1] git ls-remote https://github.com/hashicorp/go-immutable-radix 27df80928bb34bb1b0d6d0e01b9e679902e7a6b5 
SRCREV_go-immutable-radix="27df80928bb34bb1b0d6d0e01b9e679902e7a6b5"
SRC_URI += "git://github.com/hashicorp/go-immutable-radix;name=go-immutable-radix;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-immutable-radix"

# github.com/hashicorp/go-msgpack v0.5.3
# [1] git ls-remote https://github.com/hashicorp/go-msgpack be3a5be7ee2202386d02936a19ae4fbde1c77800 
SRCREV_go-msgpack="be3a5be7ee2202386d02936a19ae4fbde1c77800"
SRC_URI += "git://github.com/hashicorp/go-msgpack;name=go-msgpack;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-msgpack"

# github.com/hashicorp/go-multierror v1.1.1
# [1] git ls-remote https://github.com/hashicorp/go-multierror 9974e9ec57696378079ecc3accd3d6f29401b3a0 
SRCREV_go-multierror="9974e9ec57696378079ecc3accd3d6f29401b3a0"
SRC_URI += "git://github.com/hashicorp/go-multierror;name=go-multierror;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-multierror"

# github.com/hashicorp/go-retryablehttp v0.7.0
# [1] git ls-remote https://github.com/hashicorp/go-retryablehttp 02c1586c8f14be23e7eeb522f1094afbabf45e93 
SRCREV_go-retryablehttp="02c1586c8f14be23e7eeb522f1094afbabf45e93"
SRC_URI += "git://github.com/hashicorp/go-retryablehttp;name=go-retryablehttp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-retryablehttp"

# github.com/hashicorp/go-rootcerts v1.0.0
# [1] git ls-remote https://github.com/hashicorp/go-rootcerts 63503fb4e1eca22f9ae0f90b49c5d5538a0e87eb 
SRCREV_go-rootcerts="63503fb4e1eca22f9ae0f90b49c5d5538a0e87eb"
SRC_URI += "git://github.com/hashicorp/go-rootcerts;name=go-rootcerts;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-rootcerts"

# github.com/hashicorp/go-sockaddr v1.0.0
# [1] git ls-remote https://github.com/hashicorp/go-sockaddr a6a0d2df398f7e0e9f6e43f589c8b51cec0eb6b0 
SRCREV_go-sockaddr="a6a0d2df398f7e0e9f6e43f589c8b51cec0eb6b0"
SRC_URI += "git://github.com/hashicorp/go-sockaddr;name=go-sockaddr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-sockaddr"

# github.com/hashicorp/go-syslog v1.0.0
# [1] git ls-remote https://github.com/hashicorp/go-syslog 8d1874e3e8d1862b74e0536851e218c4571066a5 
SRCREV_go-syslog="8d1874e3e8d1862b74e0536851e218c4571066a5"
SRC_URI += "git://github.com/hashicorp/go-syslog;name=go-syslog;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-syslog"

# github.com/hashicorp/go-uuid v1.0.1
# [1] git ls-remote https://github.com/hashicorp/go-uuid 4f571afc59f3043a65f8fe6bf46d887b10a01d43 
SRCREV_go-uuid="4f571afc59f3043a65f8fe6bf46d887b10a01d43"
SRC_URI += "git://github.com/hashicorp/go-uuid;name=go-uuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go-uuid"

# github.com/hashicorp/go.net v0.0.1
# [1] git ls-remote https://github.com/hashicorp/go.net afc3cb3a421746fc66dd55b09a270c750cf536ce 
SRCREV_go.net="afc3cb3a421746fc66dd55b09a270c750cf536ce"
SRC_URI += "git://github.com/hashicorp/go.net;name=go.net;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/go.net"

# github.com/hashicorp/golang-lru v0.5.3
# [1] git ls-remote https://github.com/hashicorp/golang-lru 7f827b33c0f158ec5dfbba01bb0b14a4541fd81d 
SRCREV_golang-lru="7f827b33c0f158ec5dfbba01bb0b14a4541fd81d"
SRC_URI += "git://github.com/hashicorp/golang-lru;name=golang-lru;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/golang-lru"

# github.com/hashicorp/hcl v1.0.0
# [1] git ls-remote https://github.com/hashicorp/hcl 5592d2526badd60c172ffa95c6a3b209bea9d1ee 
SRCREV_hcl="5592d2526badd60c172ffa95c6a3b209bea9d1ee"
SRC_URI += "git://github.com/hashicorp/hcl;name=hcl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/hcl"

# github.com/hashicorp/logutils v1.0.0
# [1] git ls-remote https://github.com/hashicorp/logutils a335183dfd075f638afcc820c90591ca3c97eba6 
SRCREV_logutils="a335183dfd075f638afcc820c90591ca3c97eba6"
SRC_URI += "git://github.com/hashicorp/logutils;name=logutils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/logutils"

# github.com/hashicorp/mdns v1.0.0
# [1] git ls-remote https://github.com/hashicorp/mdns c31d3f8e4a0a5b46b118c2fd26d9da36467002c9 
SRCREV_mdns="c31d3f8e4a0a5b46b118c2fd26d9da36467002c9"
SRC_URI += "git://github.com/hashicorp/mdns;name=mdns;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/mdns"

# github.com/hashicorp/memberlist v0.1.3
# [1] git ls-remote https://github.com/hashicorp/memberlist a9da52f0668fc4321ec18e9e28dd8141621a808f 
SRCREV_memberlist="a9da52f0668fc4321ec18e9e28dd8141621a808f"
SRC_URI += "git://github.com/hashicorp/memberlist;name=memberlist;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/memberlist"

# github.com/hashicorp/serf v0.8.2
# [1] git ls-remote https://github.com/hashicorp/serf fecd23b70e35eea7babb3fd66286eb1dcfcc174d 
SRCREV_serf="fecd23b70e35eea7babb3fd66286eb1dcfcc174d"
SRC_URI += "git://github.com/hashicorp/serf;name=serf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hashicorp/serf"

# github.com/heketi/heketi v10.3.0+incompatible
# [1] git ls-remote https://github.com/heketi/heketi 44de925730c7c85cc69f11030d136b9be4773117 
SRCREV_heketi="44de925730c7c85cc69f11030d136b9be4773117"
SRC_URI += "git://github.com/heketi/heketi;name=heketi;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/heketi/heketi"

# github.com/heketi/tests v0.0.0-20151005000721-f3775cbcefd6
# [1] git ls-remote https://github.com/heketi/tests f3775cbcefd6822086c729e3ce4b70ca85a5bd21 
SRCREV_tests="f3775cbcefd6822086c729e3ce4b70ca85a5bd21"
SRC_URI += "git://github.com/heketi/tests;name=tests;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/heketi/tests"

# github.com/hpcloud/tail v1.0.0
# [1] git ls-remote https://github.com/hpcloud/tail a30252cb686a21eb2d0b98132633053ec2f7f1e5 
SRCREV_tail="a30252cb686a21eb2d0b98132633053ec2f7f1e5"
SRC_URI += "git://github.com/hpcloud/tail;name=tail;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hpcloud/tail"

# github.com/hugelgupf/socketpair v0.0.0-20190730060125-05d35a94e714
# [1] git ls-remote https://github.com/hugelgupf/socketpair 05d35a94e71444d53460c2b34dfb3dc87c99d0bd 
SRCREV_socketpair="05d35a94e71444d53460c2b34dfb3dc87c99d0bd"
SRC_URI += "git://github.com/hugelgupf/socketpair;name=socketpair;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/hugelgupf/socketpair"

# github.com/ianlancetaylor/demangle v0.0.0-20200824232613-28f6c0f3b639
# [1] git ls-remote https://github.com/ianlancetaylor/demangle 28f6c0f3b63983aaa99575ca3b693afff7996387 
SRCREV_demangle="28f6c0f3b63983aaa99575ca3b693afff7996387"
SRC_URI += "git://github.com/ianlancetaylor/demangle;name=demangle;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ianlancetaylor/demangle"

# github.com/imdario/mergo v0.3.12
# [1] git ls-remote https://github.com/imdario/mergo 29fb3d3bdc5512887f1dc9aedde6a0fed407fa8f 
SRCREV_mergo="29fb3d3bdc5512887f1dc9aedde6a0fed407fa8f"
SRC_URI += "git://github.com/imdario/mergo;name=mergo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/imdario/mergo"

# github.com/inconshreveable/mousetrap v1.0.0
# [1] git ls-remote https://github.com/inconshreveable/mousetrap 76626ae9c91c4f2a10f34cad8ce83ea42c93bb75 
SRCREV_mousetrap="76626ae9c91c4f2a10f34cad8ce83ea42c93bb75"
SRC_URI += "git://github.com/inconshreveable/mousetrap;name=mousetrap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/inconshreveable/mousetrap"

# github.com/insomniacslk/dhcp v0.0.0-20210120172423-cc9239ac6294
# [1] git ls-remote https://github.com/insomniacslk/dhcp cc9239ac62943a78e89ef4880c8ebdd0ca9ae21e 
SRCREV_dhcp="cc9239ac62943a78e89ef4880c8ebdd0ca9ae21e"
SRC_URI += "git://github.com/insomniacslk/dhcp;name=dhcp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/insomniacslk/dhcp"

# github.com/ishidawataru/sctp v0.0.0-20190723014705-7c296d48a2b5
# [1] git ls-remote https://github.com/ishidawataru/sctp 7c296d48a2b553e41cc06904a1e6317a20694dc0 
SRCREV_sctp="7c296d48a2b553e41cc06904a1e6317a20694dc0"
SRC_URI += "git://github.com/ishidawataru/sctp;name=sctp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ishidawataru/sctp"

# github.com/j-keck/arping v0.0.0-20160618110441-2cf9dc699c56
# [1] git ls-remote https://github.com/j-keck/arping 2cf9dc699c5640a7e2c81403a44127bf28033600 
SRCREV_arping="2cf9dc699c5640a7e2c81403a44127bf28033600"
SRC_URI += "git://github.com/j-keck/arping;name=arping;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/j-keck/arping"

# github.com/jessevdk/go-flags v1.3.0
# [1] git ls-remote https://github.com/jessevdk/go-flags 96dc06278ce32a0e9d957d590bb987c81ee66407 
SRCREV_go-flags="96dc06278ce32a0e9d957d590bb987c81ee66407"
SRC_URI += "git://github.com/jessevdk/go-flags;name=go-flags;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jessevdk/go-flags"

# github.com/jmespath/go-jmespath v0.4.0
# [1] git ls-remote https://github.com/jmespath/go-jmespath 9c15c4acd1ffeaa5447b110dd3b427f1afcced99 
SRCREV_go-jmespath="9c15c4acd1ffeaa5447b110dd3b427f1afcced99"
SRC_URI += "git://github.com/jmespath/go-jmespath;name=go-jmespath;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jmespath/go-jmespath"

# github.com/jmespath/go-jmespath/internal/testify v1.5.1
# [1] git ls-remote https://github.com/jmespath/go-jmespath 17482bad3800f5b47ee3b5b0a01e1a7dbcf55493 
SRCREV_testify="17482bad3800f5b47ee3b5b0a01e1a7dbcf55493"
SRC_URI += "git://github.com/jmespath/go-jmespath;name=testify;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jmespath/go-jmespath/internal/testify"

# github.com/joho/godotenv v0.0.0-20161216230537-726cc8b906e3
# [1] git ls-remote https://github.com/joho/godotenv 726cc8b906e3d31c70a9671c90a13716a8d3f50d 
SRCREV_godotenv="726cc8b906e3d31c70a9671c90a13716a8d3f50d"
SRC_URI += "git://github.com/joho/godotenv;name=godotenv;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/joho/godotenv"

# github.com/jonboulle/clockwork v0.2.2
# [1] git ls-remote https://github.com/jonboulle/clockwork b019beee95aca697d4f042c77f9cf2d1af979960 
SRCREV_clockwork="b019beee95aca697d4f042c77f9cf2d1af979960"
SRC_URI += "git://github.com/jonboulle/clockwork;name=clockwork;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jonboulle/clockwork"

# github.com/josharian/intern v1.0.0
# [1] git ls-remote https://github.com/josharian/intern 8e6ff32b3e7c0b018c43953085fe2ac330fe9acd 
SRCREV_intern="8e6ff32b3e7c0b018c43953085fe2ac330fe9acd"
SRC_URI += "git://github.com/josharian/intern;name=intern;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/josharian/intern"

# github.com/josharian/native v0.0.0-20200817173448-b6b71def0850
# [1] git ls-remote https://github.com/josharian/native b6b71def0850a2fbd7e6875f8e28217a48c5bcb4 
SRCREV_native="b6b71def0850a2fbd7e6875f8e28217a48c5bcb4"
SRC_URI += "git://github.com/josharian/native;name=native;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/josharian/native"

# github.com/jpillora/backoff v1.0.0
# [1] git ls-remote https://github.com/jpillora/backoff d80867952dff4e2fbfb4280ded4ff94d67790457 
SRCREV_backoff="d80867952dff4e2fbfb4280ded4ff94d67790457"
SRC_URI += "git://github.com/jpillora/backoff;name=backoff;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jpillora/backoff"

# github.com/jsimonetti/rtnetlink v0.0.0-20211022192332-93da33804786
# [1] git ls-remote https://github.com/jsimonetti/rtnetlink 93da33804786e0d138aea412b38d80dd0099b941 
SRCREV_rtnetlink="93da33804786e0d138aea412b38d80dd0099b941"
SRC_URI += "git://github.com/jsimonetti/rtnetlink;name=rtnetlink;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jsimonetti/rtnetlink"

# github.com/json-iterator/go v1.1.11
# [1] git ls-remote https://github.com/json-iterator/go e6b9536d3649bda3e8842bb7e4fab489d79a97ea 
SRCREV_go12="e6b9536d3649bda3e8842bb7e4fab489d79a97ea"
SRC_URI += "git://github.com/json-iterator/go;name=go12;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/json-iterator/go"

# github.com/jstemmer/go-junit-report v0.9.1
# [1] git ls-remote https://github.com/jstemmer/go-junit-report 601852a893a84bd7426fbcb1579a64b84f349c62 
SRCREV_go-junit-report="601852a893a84bd7426fbcb1579a64b84f349c62"
SRC_URI += "git://github.com/jstemmer/go-junit-report;name=go-junit-report;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jstemmer/go-junit-report"

# github.com/jtolds/gls v4.20.0+incompatible
# [1] git ls-remote https://github.com/jtolds/gls b4936e06046bbecbb94cae9c18127ebe510a2cb9 
SRCREV_gls="b4936e06046bbecbb94cae9c18127ebe510a2cb9"
SRC_URI += "git://github.com/jtolds/gls;name=gls;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jtolds/gls"

# github.com/julienschmidt/httprouter v1.3.0
# [1] git ls-remote https://github.com/julienschmidt/httprouter 4eec211fa4e8df74ed978dc5681612131854144f 
SRCREV_httprouter="4eec211fa4e8df74ed978dc5681612131854144f"
SRC_URI += "git://github.com/julienschmidt/httprouter;name=httprouter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/julienschmidt/httprouter"

# github.com/jung-kurt/gofpdf v1.0.3-0.20190309125859-24315acbbda5
# [1] git ls-remote https://github.com/jung-kurt/gofpdf 24315acbbda57c4f6b80c8441fd108087dd7e305 
SRCREV_gofpdf="24315acbbda57c4f6b80c8441fd108087dd7e305"
SRC_URI += "git://github.com/jung-kurt/gofpdf;name=gofpdf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/jung-kurt/gofpdf"

# github.com/k-sone/critbitgo v1.3.1-0.20191024122315-48c9e1530131
# [1] git ls-remote https://github.com/k-sone/critbitgo 48c9e1530131e6e7726ef4c05759e7fc0ab32e7f 
SRCREV_critbitgo="48c9e1530131e6e7726ef4c05759e7fc0ab32e7f"
SRC_URI += "git://github.com/k-sone/critbitgo;name=critbitgo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k-sone/critbitgo"

# github.com/k3s-io/helm-controller v0.11.7
# [1] git ls-remote https://github.com/k3s-io/helm-controller f8b5a878922bd9a9eb5a9e8e65a3552cf90ed2c4 
SRCREV_helm-controller="f8b5a878922bd9a9eb5a9e8e65a3552cf90ed2c4"
SRC_URI += "git://github.com/k3s-io/helm-controller;name=helm-controller;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/helm-controller"

# github.com/k3s-io/kine v0.8.1
# [1] git ls-remote https://github.com/k3s-io/kine c1edece7772b4ff4f1f03f01d5218fbfe854c0cc 
SRCREV_kine="c1edece7772b4ff4f1f03f01d5218fbfe854c0cc"
SRC_URI += "git://github.com/k3s-io/kine;name=kine;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kine"

# github.com/karrick/godirwalk v1.16.1
# [1] git ls-remote https://github.com/karrick/godirwalk 4b98035d5f574ae5b2bb1951efb2df23aa4f06a3 
SRCREV_godirwalk="4b98035d5f574ae5b2bb1951efb2df23aa4f06a3"
SRC_URI += "git://github.com/karrick/godirwalk;name=godirwalk;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/karrick/godirwalk"

# github.com/kisielk/errcheck v1.5.0
# [1] git ls-remote https://github.com/kisielk/errcheck ee08a456fc430219ad80ce5af98415bcc027a219 
SRCREV_errcheck="ee08a456fc430219ad80ce5af98415bcc027a219"
SRC_URI += "git://github.com/kisielk/errcheck;name=errcheck;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kisielk/errcheck"

# github.com/kisielk/gotool v1.0.0
# [1] git ls-remote https://github.com/kisielk/gotool 80517062f582ea3340cd4baf70e86d539ae7d84d 
SRCREV_gotool="80517062f582ea3340cd4baf70e86d539ae7d84d"
SRC_URI += "git://github.com/kisielk/gotool;name=gotool;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kisielk/gotool"

# github.com/klauspost/compress v1.13.6
# [1] git ls-remote https://github.com/klauspost/compress 38d4ba985ac157cb858763e016645e14e74c13c4 
SRCREV_compress="38d4ba985ac157cb858763e016645e14e74c13c4"
SRC_URI += "git://github.com/klauspost/compress;name=compress;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/klauspost/compress"

# github.com/klauspost/cpuid v1.3.1
# [1] git ls-remote https://github.com/klauspost/cpuid 750c0591dbbd50ef88371c665ad49e426a4b830b 
SRCREV_cpuid="750c0591dbbd50ef88371c665ad49e426a4b830b"
SRC_URI += "git://github.com/klauspost/cpuid;name=cpuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/klauspost/cpuid"

# github.com/konsorten/go-windows-terminal-sequences v1.0.3
# [1] git ls-remote https://github.com/konsorten/go-windows-terminal-sequences edb144dfd453055e1e49a3d8b410a660b5a87613 
SRCREV_go-windows-terminal-sequences="edb144dfd453055e1e49a3d8b410a660b5a87613"
SRC_URI += "git://github.com/konsorten/go-windows-terminal-sequences;name=go-windows-terminal-sequences;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/konsorten/go-windows-terminal-sequences"

# github.com/kr/fs v0.1.0
# [1] git ls-remote https://github.com/kr/fs a4edaa46e98ce745306fb4bf9a584000f0ccb0cd 
SRCREV_fs="a4edaa46e98ce745306fb4bf9a584000f0ccb0cd"
SRC_URI += "git://github.com/kr/fs;name=fs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kr/fs"

# github.com/kr/logfmt v0.0.0-20140226030751-b84e30acd515
# [1] git ls-remote https://github.com/kr/logfmt b84e30acd515aadc4b783ad4ff83aff3299bdfe0 
SRCREV_logfmt1="b84e30acd515aadc4b783ad4ff83aff3299bdfe0"
SRC_URI += "git://github.com/kr/logfmt;name=logfmt1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kr/logfmt"

# github.com/kr/pretty v0.2.1
# [1] git ls-remote https://github.com/kr/pretty 326f0883a47c4b88a699dc12c4ca20164aadd512 
SRCREV_pretty="326f0883a47c4b88a699dc12c4ca20164aadd512"
SRC_URI += "git://github.com/kr/pretty;name=pretty;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kr/pretty"

# github.com/kr/pty v1.1.5
# [1] git ls-remote https://github.com/kr/pty b6e1bdd4a4f88614e0c6e5e8089c7abed98aae17 
SRCREV_pty1="b6e1bdd4a4f88614e0c6e5e8089c7abed98aae17"
SRC_URI += "git://github.com/kr/pty;name=pty1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kr/pty"

# github.com/kr/text v0.2.0
# [1] git ls-remote https://github.com/kr/text 0e5f52c28dd72ab84daeb81b5a51f20fdc35f9c5 
SRCREV_text="0e5f52c28dd72ab84daeb81b5a51f20fdc35f9c5"
SRC_URI += "git://github.com/kr/text;name=text;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kr/text"

# github.com/k3s-io/cri-tools v1.21.0-k3s1
# [1] git ls-remote https://github.com/k3s-io/cri-tools 47c43d3b6f0254aec4746dbc747f2178f0188647 
SRCREV_cri-tools="47c43d3b6f0254aec4746dbc747f2178f0188647"
SRC_URI += "git://github.com/k3s-io/cri-tools;name=cri-tools;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kubernetes-sigs/cri-tools"

# github.com/kylelemons/godebug v0.0.0-20170820004349-d65d576e9348
# [1] git ls-remote https://github.com/kylelemons/godebug d65d576e9348f5982d7f6d83682b694e731a45c6 
SRCREV_godebug="d65d576e9348f5982d7f6d83682b694e731a45c6"
SRC_URI += "git://github.com/kylelemons/godebug;name=godebug;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kylelemons/godebug"

# github.com/lib/pq v1.10.2
# [1] git ls-remote https://github.com/lib/pq 2da6713d67f03911a05b1b6559adc85927fe076e 
SRCREV_pq="2da6713d67f03911a05b1b6559adc85927fe076e"
SRC_URI += "git://github.com/lib/pq;name=pq;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/lib/pq"

# github.com/libopenstorage/openstorage v1.0.0
# [1] git ls-remote https://github.com/libopenstorage/openstorage a0608a35f2d0151fe79b4761a8780621fd83dc27 
SRCREV_openstorage="a0608a35f2d0151fe79b4761a8780621fd83dc27"
SRC_URI += "git://github.com/libopenstorage/openstorage;name=openstorage;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/libopenstorage/openstorage"

# github.com/liggitt/tabwriter v0.0.0-20181228230101-89fcab3d43de
# [1] git ls-remote https://github.com/liggitt/tabwriter 89fcab3d43de07060e4fd4c1547430ed57e87f24 
SRCREV_tabwriter="89fcab3d43de07060e4fd4c1547430ed57e87f24"
SRC_URI += "git://github.com/liggitt/tabwriter;name=tabwriter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/liggitt/tabwriter"

# github.com/lithammer/dedent v1.1.0
# [1] git ls-remote https://github.com/lithammer/dedent 7da0ef12e7f6e16e724290d47c139520f1ad6171 
SRCREV_dedent="7da0ef12e7f6e16e724290d47c139520f1ad6171"
SRC_URI += "git://github.com/lithammer/dedent;name=dedent;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/lithammer/dedent"

# github.com/lpabon/godbc v0.1.1
# [1] git ls-remote https://github.com/lpabon/godbc 19db9f027401ab26533e2f647840c2c691a48572 
SRCREV_godbc="19db9f027401ab26533e2f647840c2c691a48572"
SRC_URI += "git://github.com/lpabon/godbc;name=godbc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/lpabon/godbc"

# github.com/magiconair/properties v1.8.5
# [1] git ls-remote https://github.com/magiconair/properties bf326db7888cd3bdb60272aa8806e9d7a948e7d3 
SRCREV_properties="bf326db7888cd3bdb60272aa8806e9d7a948e7d3"
SRC_URI += "git://github.com/magiconair/properties;name=properties;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/magiconair/properties"

# github.com/mailru/easyjson v0.7.6
# [1] git ls-remote https://github.com/mailru/easyjson 8ab5ff9cd8e4e432e8b79f6c47d324a31dd803cf 
SRCREV_easyjson="8ab5ff9cd8e4e432e8b79f6c47d324a31dd803cf"
SRC_URI += "git://github.com/mailru/easyjson;name=easyjson;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mailru/easyjson"

# github.com/mattn/go-colorable v0.1.4
# [1] git ls-remote https://github.com/mattn/go-colorable 98ec13f34aabf44cc914c65a1cfb7b9bc815aef1 
SRCREV_go-colorable="98ec13f34aabf44cc914c65a1cfb7b9bc815aef1"
SRC_URI += "git://github.com/mattn/go-colorable;name=go-colorable;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-colorable"

# github.com/mattn/go-isatty v0.0.11
# [1] git ls-remote https://github.com/mattn/go-isatty 31745d66dd679ac0ac4f8d3ecff168fce6170c6a 
SRCREV_go-isatty="31745d66dd679ac0ac4f8d3ecff168fce6170c6a"
SRC_URI += "git://github.com/mattn/go-isatty;name=go-isatty;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-isatty"

# github.com/mattn/go-runewidth v0.0.9
# [1] git ls-remote https://github.com/mattn/go-runewidth 14e809f6d78fcf9f48ff9b70981472b64c05f754 
SRCREV_go-runewidth="14e809f6d78fcf9f48ff9b70981472b64c05f754"
SRC_URI += "git://github.com/mattn/go-runewidth;name=go-runewidth;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-runewidth"

# github.com/mattn/go-shellwords v1.0.3
# [1] git ls-remote https://github.com/mattn/go-shellwords 02e3cf038dcea8290e44424da473dd12be796a8a 
SRCREV_go-shellwords="02e3cf038dcea8290e44424da473dd12be796a8a"
SRC_URI += "git://github.com/mattn/go-shellwords;name=go-shellwords;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-shellwords"

# github.com/mattn/go-sqlite3 v1.14.8
# [1] git ls-remote https://github.com/mattn/go-sqlite3 cba6eaee486f22a1b0f3208b145673ed951cb840 
SRCREV_go-sqlite3="cba6eaee486f22a1b0f3208b145673ed951cb840"
SRC_URI += "git://github.com/mattn/go-sqlite3;name=go-sqlite3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mattn/go-sqlite3"

# github.com/matttproud/golang_protobuf_extensions v1.0.2-0.20181231171920-c182affec369
# [1] git ls-remote https://github.com/matttproud/golang_protobuf_extensions c182affec369e30f25d3eb8cd8a478dee585ae7d 
SRCREV_golang_protobuf_extensions="c182affec369e30f25d3eb8cd8a478dee585ae7d"
SRC_URI += "git://github.com/matttproud/golang_protobuf_extensions;name=golang_protobuf_extensions;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/matttproud/golang_protobuf_extensions"

# github.com/mdlayher/ethernet v0.0.0-20190606142754-0394541c37b7
# [1] git ls-remote https://github.com/mdlayher/ethernet 0394541c37b7f86a10e0b49492f6d4f605c34163 
SRCREV_ethernet="0394541c37b7f86a10e0b49492f6d4f605c34163"
SRC_URI += "git://github.com/mdlayher/ethernet;name=ethernet;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/ethernet"

# github.com/mdlayher/ethtool v0.0.0-20211028163843-288d040e9d60
# [1] git ls-remote https://github.com/mdlayher/ethtool 288d040e9d60a1b55b53566a1624be427cfeef97 
SRCREV_ethtool="288d040e9d60a1b55b53566a1624be427cfeef97"
SRC_URI += "git://github.com/mdlayher/ethtool;name=ethtool;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/ethtool"

# github.com/mdlayher/genetlink v1.1.0
# [1] git ls-remote https://github.com/mdlayher/genetlink 3a8264b219e1587c8c5814f9a4cf8fe56c530a32 
SRCREV_genetlink="3a8264b219e1587c8c5814f9a4cf8fe56c530a32"
SRC_URI += "git://github.com/mdlayher/genetlink;name=genetlink;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/genetlink"

# github.com/mdlayher/netlink v1.4.2
# [1] git ls-remote https://github.com/mdlayher/netlink e7b35cd0b91ce844c2134741dfdc69fe5aee695d 
SRCREV_netlink="e7b35cd0b91ce844c2134741dfdc69fe5aee695d"
SRC_URI += "git://github.com/mdlayher/netlink;name=netlink;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/netlink"

# github.com/mdlayher/raw v0.0.0-20191009151244-50f2db8cc065
# [1] git ls-remote https://github.com/mdlayher/raw 50f2db8cc0658568575938a39dbaa46172921d98 
SRCREV_raw="50f2db8cc0658568575938a39dbaa46172921d98"
SRC_URI += "git://github.com/mdlayher/raw;name=raw;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/raw"

# github.com/mdlayher/socket v0.0.0-20211102153432-57e3fa563ecb
# [1] git ls-remote https://github.com/mdlayher/socket 57e3fa563ecb8fbbbf28b56c674ce382ae48f7db 
SRCREV_socket="57e3fa563ecb8fbbbf28b56c674ce382ae48f7db"
SRC_URI += "git://github.com/mdlayher/socket;name=socket;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mdlayher/socket"

# github.com/miekg/dns v1.0.14
# [1] git ls-remote https://github.com/miekg/dns 915ca3d5ffd945235828a097c917311a9d86ebb4 
SRCREV_dns="915ca3d5ffd945235828a097c917311a9d86ebb4"
SRC_URI += "git://github.com/miekg/dns;name=dns;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/miekg/dns"

# github.com/miekg/pkcs11 v1.0.3
# [1] git ls-remote https://github.com/miekg/pkcs11 210dc1e16747c5ba98a03bcbcf728c38086ea357 
SRCREV_pkcs11="210dc1e16747c5ba98a03bcbcf728c38086ea357"
SRC_URI += "git://github.com/miekg/pkcs11;name=pkcs11;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/miekg/pkcs11"

# github.com/mikioh/ipaddr v0.0.0-20190404000644-d465c8ab6721
# [1] git ls-remote https://github.com/mikioh/ipaddr d465c8ab672111787b24b8f03326449059a4aa33 
SRCREV_ipaddr="d465c8ab672111787b24b8f03326449059a4aa33"
SRC_URI += "git://github.com/mikioh/ipaddr;name=ipaddr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mikioh/ipaddr"

# github.com/mindprince/gonvml v0.0.0-20190828220739-9ebdce4bb989
# [1] git ls-remote https://github.com/mindprince/gonvml 9ebdce4bb98934573700a3bfc2f8e791934a578d 
SRCREV_gonvml="9ebdce4bb98934573700a3bfc2f8e791934a578d"
SRC_URI += "git://github.com/mindprince/gonvml;name=gonvml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mindprince/gonvml"

# github.com/minio/md5-simd v1.1.0
# [1] git ls-remote https://github.com/minio/md5-simd d302c3dbe3e6573d7010992e3927355eb0e1ab91 
SRCREV_md5-simd="d302c3dbe3e6573d7010992e3927355eb0e1ab91"
SRC_URI += "git://github.com/minio/md5-simd;name=md5-simd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/md5-simd"

# github.com/minio/minio-go/v7 v7.0.7
# [1] git ls-remote https://github.com/minio/minio-go 2fc8929815e0a488f065b47bc1271ab0d4238f82 
SRCREV_v7="2fc8929815e0a488f065b47bc1271ab0d4238f82"
SRC_URI += "git://github.com/minio/minio-go;name=v7;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/minio-go/v7"

# github.com/minio/sha256-simd v0.1.1
# [1] git ls-remote https://github.com/minio/sha256-simd 6de4475307716de15b286880ff321c9547086fdd 
SRCREV_sha256-simd="6de4475307716de15b286880ff321c9547086fdd"
SRC_URI += "git://github.com/minio/sha256-simd;name=sha256-simd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/sha256-simd"

# github.com/minio/sio v0.2.1
# [1] git ls-remote https://github.com/minio/sio ae0213457e8a919f927bb03909b2135b6ca02ef1 
SRCREV_sio="ae0213457e8a919f927bb03909b2135b6ca02ef1"
SRC_URI += "git://github.com/minio/sio;name=sio;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/minio/sio"

# github.com/mistifyio/go-zfs v2.1.2-0.20190413222219-f784269be439+incompatible
# [1] git ls-remote https://github.com/mistifyio/go-zfs f784269be439d704d3dfa1906f45dd848fed2beb 
SRCREV_go-zfs="f784269be439d704d3dfa1906f45dd848fed2beb"
SRC_URI += "git://github.com/mistifyio/go-zfs;name=go-zfs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mistifyio/go-zfs"

# github.com/mitchellh/cli v1.0.0
# [1] git ls-remote https://github.com/mitchellh/cli 3d22a244be8aa6fb16ac24af0e195c08b7d973aa 
SRCREV_cli1="3d22a244be8aa6fb16ac24af0e195c08b7d973aa"
SRC_URI += "git://github.com/mitchellh/cli;name=cli1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/cli"

# github.com/mitchellh/go-homedir v1.1.0
# [1] git ls-remote https://github.com/mitchellh/go-homedir af06845cf3004701891bf4fdb884bfe4920b3727 
SRCREV_go-homedir="af06845cf3004701891bf4fdb884bfe4920b3727"
SRC_URI += "git://github.com/mitchellh/go-homedir;name=go-homedir;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/go-homedir"

# github.com/mitchellh/go-testing-interface v1.0.0
# [1] git ls-remote https://github.com/mitchellh/go-testing-interface 6d0b8010fcc857872e42fc6c931227569016843c 
SRCREV_go-testing-interface="6d0b8010fcc857872e42fc6c931227569016843c"
SRC_URI += "git://github.com/mitchellh/go-testing-interface;name=go-testing-interface;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/go-testing-interface"

# github.com/mitchellh/go-wordwrap v1.0.0
# [1] git ls-remote https://github.com/mitchellh/go-wordwrap 9e67c67572bc5dd02aef930e2b0ae3c02a4b5a5c 
SRCREV_go-wordwrap="9e67c67572bc5dd02aef930e2b0ae3c02a4b5a5c"
SRC_URI += "git://github.com/mitchellh/go-wordwrap;name=go-wordwrap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/go-wordwrap"

# github.com/mitchellh/gox v0.4.0
# [1] git ls-remote https://github.com/mitchellh/gox ce32ae4c610e1fed97dd0e0b5155d16d2638ffb1 
SRCREV_gox="ce32ae4c610e1fed97dd0e0b5155d16d2638ffb1"
SRC_URI += "git://github.com/mitchellh/gox;name=gox;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/gox"

# github.com/mitchellh/iochan v1.0.0
# [1] git ls-remote https://github.com/mitchellh/iochan b6e3aadd28864e14dae41ff5c7261455b1242d24 
SRCREV_iochan="b6e3aadd28864e14dae41ff5c7261455b1242d24"
SRC_URI += "git://github.com/mitchellh/iochan;name=iochan;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/iochan"

# github.com/mitchellh/mapstructure v1.4.1
# [1] git ls-remote https://github.com/mitchellh/mapstructure 8ebf2d61a8b4adcce25fc9fc9b76e8452a00672f 
SRCREV_mapstructure="8ebf2d61a8b4adcce25fc9fc9b76e8452a00672f"
SRC_URI += "git://github.com/mitchellh/mapstructure;name=mapstructure;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mitchellh/mapstructure"

# github.com/moby/ipvs v1.0.1
# [1] git ls-remote https://github.com/moby/ipvs f72130f9871536f131d0f4be5a4d99ad2591218c 
SRCREV_ipvs="f72130f9871536f131d0f4be5a4d99ad2591218c"
SRC_URI += "git://github.com/moby/ipvs;name=ipvs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/ipvs"

# github.com/moby/locker v1.0.1
# [1] git ls-remote https://github.com/moby/locker e15721d7a0126008853f3cefbdbb368685cd1f4d 
SRCREV_locker="e15721d7a0126008853f3cefbdbb368685cd1f4d"
SRC_URI += "git://github.com/moby/locker;name=locker;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/locker"

# github.com/moby/spdystream v0.2.0
# [1] git ls-remote https://github.com/moby/spdystream dbc715126c0e3fa07721879c6d265b2b82c71e5b 
SRCREV_spdystream="dbc715126c0e3fa07721879c6d265b2b82c71e5b"
SRC_URI += "git://github.com/moby/spdystream;name=spdystream;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/spdystream"

# github.com/moby/sys/mountinfo v0.5.0
# [1] git ls-remote https://github.com/moby/sys 416188aff8404d549e1e34a50e513befeb11c3b9 
SRCREV_mountinfo="416188aff8404d549e1e34a50e513befeb11c3b9"
SRC_URI += "git://github.com/moby/sys;name=mountinfo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/sys/mountinfo"

# github.com/moby/term v0.0.0-20210610120745-9d4ed1856297
# [1] git ls-remote https://github.com/moby/term 9d4ed185629744f381f269030675cb1957e2da94 
SRCREV_term="9d4ed185629744f381f269030675cb1957e2da94"
SRC_URI += "git://github.com/moby/term;name=term;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/term"

# github.com/moby/vpnkit v0.5.0
# [1] git ls-remote https://github.com/moby/vpnkit 7f0eff0dd99b576c5474de53b4454a157c642834 
SRCREV_vpnkit="7f0eff0dd99b576c5474de53b4454a157c642834"
SRC_URI += "git://github.com/moby/vpnkit;name=vpnkit;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/moby/vpnkit"

# github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd
# [1] git ls-remote https://github.com/modern-go/concurrent bacd9c7ef1dd9b15be4a9909b8ac7a4e313eec94 
SRCREV_concurrent="bacd9c7ef1dd9b15be4a9909b8ac7a4e313eec94"
SRC_URI += "git://github.com/modern-go/concurrent;name=concurrent;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/modern-go/concurrent"

# github.com/modern-go/reflect2 v1.0.1
# [1] git ls-remote https://github.com/modern-go/reflect2 94122c33edd36123c84d5368cfb2b69df93a0ec8 
SRCREV_reflect2="94122c33edd36123c84d5368cfb2b69df93a0ec8"
SRC_URI += "git://github.com/modern-go/reflect2;name=reflect2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/modern-go/reflect2"

# github.com/mohae/deepcopy v0.0.0-20170929034955-c48cc78d4826
# [1] git ls-remote https://github.com/mohae/deepcopy c48cc78d482608239f6c4c92a4abd87eb8761c90 
SRCREV_deepcopy="c48cc78d482608239f6c4c92a4abd87eb8761c90"
SRC_URI += "git://github.com/mohae/deepcopy;name=deepcopy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mohae/deepcopy"

# github.com/monochromegane/go-gitignore v0.0.0-20200626010858-205db1a8cc00
# [1] git ls-remote https://github.com/monochromegane/go-gitignore 205db1a8cc001de79230472da52edde4974df734 
SRCREV_go-gitignore="205db1a8cc001de79230472da52edde4974df734"
SRC_URI += "git://github.com/monochromegane/go-gitignore;name=go-gitignore;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/monochromegane/go-gitignore"

# github.com/morikuni/aec v1.0.0
# [1] git ls-remote https://github.com/morikuni/aec 39771216ff4c63d11f5e604076f9c45e8be1067b 
SRCREV_aec="39771216ff4c63d11f5e604076f9c45e8be1067b"
SRC_URI += "git://github.com/morikuni/aec;name=aec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/morikuni/aec"

# github.com/mrunalp/fileutils v0.5.0
# [1] git ls-remote https://github.com/mrunalp/fileutils d7fdd64cc1cabe10bc154ee7d2318b07b7f296ef 
SRCREV_fileutils="d7fdd64cc1cabe10bc154ee7d2318b07b7f296ef"
SRC_URI += "git://github.com/mrunalp/fileutils;name=fileutils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mrunalp/fileutils"

# github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822
# [1] git ls-remote https://github.com/munnerz/goautoneg a7dc8b61c822528f973a5e4e7b272055c6fdb43e 
SRCREV_goautoneg="a7dc8b61c822528f973a5e4e7b272055c6fdb43e"
SRC_URI += "git://github.com/munnerz/goautoneg;name=goautoneg;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/munnerz/goautoneg"

# github.com/mvdan/xurls v1.1.0
# [1] git ls-remote https://github.com/mvdan/xurls c174a0a92fc78706d57afd13cfb0197ec28d15b3 
SRCREV_xurls="c174a0a92fc78706d57afd13cfb0197ec28d15b3"
SRC_URI += "git://github.com/mvdan/xurls;name=xurls;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mvdan/xurls"

# github.com/mwitkow/go-conntrack v0.0.0-20190716064945-2f068394615f
# [1] git ls-remote https://github.com/mwitkow/go-conntrack 2f068394615f73e460c2f3d2c158b0ad9321cadb 
SRCREV_go-conntrack="2f068394615f73e460c2f3d2c158b0ad9321cadb"
SRC_URI += "git://github.com/mwitkow/go-conntrack;name=go-conntrack;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mwitkow/go-conntrack"

# github.com/mxk/go-flowrate v0.0.0-20140419014527-cca7078d478f
# [1] git ls-remote https://github.com/mxk/go-flowrate cca7078d478f8520f85629ad7c68962d31ed7682 
SRCREV_go-flowrate="cca7078d478f8520f85629ad7c68962d31ed7682"
SRC_URI += "git://github.com/mxk/go-flowrate;name=go-flowrate;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/mxk/go-flowrate"

# github.com/natefinch/lumberjack v2.0.0+incompatible
# [1] git ls-remote https://github.com/natefinch/lumberjack 2a59cad198e07a0ea1fad0b3d6733626861b5c65 
SRCREV_lumberjack="2a59cad198e07a0ea1fad0b3d6733626861b5c65"
SRC_URI += "git://github.com/natefinch/lumberjack;name=lumberjack;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/natefinch/lumberjack"

# github.com/niemeyer/pretty v0.0.0-20200227124842-a10e7caefd8e
# [1] git ls-remote https://github.com/niemeyer/pretty a10e7caefd8e0d600cea437f5c3613aeb1553d56 
SRCREV_pretty1="a10e7caefd8e0d600cea437f5c3613aeb1553d56"
SRC_URI += "git://github.com/niemeyer/pretty;name=pretty1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/niemeyer/pretty"

# github.com/nxadm/tail v1.4.8
# [1] git ls-remote https://github.com/nxadm/tail abad231d8d07ef91e09cd4c4c457cac35ed3bbb9 
SRCREV_tail1="abad231d8d07ef91e09cd4c4c457cac35ed3bbb9"
SRC_URI += "git://github.com/nxadm/tail;name=tail1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/nxadm/tail"

# github.com/oklog/ulid v1.3.1
# [1] git ls-remote https://github.com/oklog/ulid 02a8604050d8466dd915307496174adb9be4593a 
SRCREV_ulid="02a8604050d8466dd915307496174adb9be4593a"
SRC_URI += "git://github.com/oklog/ulid;name=ulid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/oklog/ulid"

# github.com/olekukonko/tablewriter v0.0.5
# [1] git ls-remote https://github.com/olekukonko/tablewriter c7d2a8a09b076b70918308a3cd95464b2ae3b5d8 
SRCREV_tablewriter="c7d2a8a09b076b70918308a3cd95464b2ae3b5d8"
SRC_URI += "git://github.com/olekukonko/tablewriter;name=tablewriter;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/olekukonko/tablewriter"

# github.com/onsi/ginkgo v1.16.4
# [1] git ls-remote https://github.com/onsi/ginkgo d125cd027fee341b3b3d65858a4121cf4931fead 
SRCREV_ginkgo="d125cd027fee341b3b3d65858a4121cf4931fead"
SRC_URI += "git://github.com/onsi/ginkgo;name=ginkgo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/onsi/ginkgo"

# github.com/onsi/gomega v1.11.0
# [1] git ls-remote https://github.com/onsi/gomega d9ee1e278b3bd59704a0521284ce8f8b25273b20 
SRCREV_gomega="d9ee1e278b3bd59704a0521284ce8f8b25273b20"
SRC_URI += "git://github.com/onsi/gomega;name=gomega;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/onsi/gomega"

# github.com/opencontainers/go-digest v1.0.0
# [1] git ls-remote https://github.com/opencontainers/go-digest 4a41a1fddd8208cc64f911e551a7f361716f8ae5 
SRCREV_go-digest="4a41a1fddd8208cc64f911e551a7f361716f8ae5"
SRC_URI += "git://github.com/opencontainers/go-digest;name=go-digest;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/go-digest"

# github.com/opencontainers/image-spec v1.0.2
# [1] git ls-remote https://github.com/opencontainers/image-spec a8af30d0c9aac77c7c2927df80133222f0f315e2 
SRCREV_image-spec="a8af30d0c9aac77c7c2927df80133222f0f315e2"
SRC_URI += "git://github.com/opencontainers/image-spec;name=image-spec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/image-spec"

# github.com/opencontainers/runc v1.0.3
# [1] git ls-remote https://github.com/opencontainers/runc e4bccdbd64361ac5ea8ba90bb8845add78f957a6 
SRCREV_runc="e4bccdbd64361ac5ea8ba90bb8845add78f957a6"
SRC_URI += "git://github.com/opencontainers/runc;name=runc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/runc"

# github.com/opencontainers/runtime-spec v1.0.3-0.20210316141917-a8c4a9ee0f6b
# [1] git ls-remote https://github.com/opencontainers/runtime-spec a8c4a9ee0f6b5a0b994c5c23c68725394e2b0d9d 
SRCREV_runtime-spec="a8c4a9ee0f6b5a0b994c5c23c68725394e2b0d9d"
SRC_URI += "git://github.com/opencontainers/runtime-spec;name=runtime-spec;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/runtime-spec"

# github.com/opencontainers/selinux v1.8.2
# [1] git ls-remote https://github.com/opencontainers/selinux 76bc82e11d854d3e40c08889d13c98abcea72ea2 
SRCREV_selinux="76bc82e11d854d3e40c08889d13c98abcea72ea2"
SRC_URI += "git://github.com/opencontainers/selinux;name=selinux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opencontainers/selinux"

# github.com/opentracing/opentracing-go v1.1.0
# [1] git ls-remote https://github.com/opentracing/opentracing-go 659c90643e714681897ec2521c60567dd21da733 
SRCREV_opentracing-go="659c90643e714681897ec2521c60567dd21da733"
SRC_URI += "git://github.com/opentracing/opentracing-go;name=opentracing-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/opentracing/opentracing-go"

# github.com/osrg/gobgp v0.0.0-20210801043420-9e48a36ed97c
# [1] git ls-remote https://github.com/osrg/gobgp 9e48a36ed97c699e2a5b5d8dfd3f9fb6e6119e0b 
SRCREV_gobgp="9e48a36ed97c699e2a5b5d8dfd3f9fb6e6119e0b"
SRC_URI += "git://github.com/osrg/gobgp;name=gobgp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/osrg/gobgp"

# github.com/otiai10/copy v1.6.0
# [1] git ls-remote https://github.com/otiai10/copy edeb9f37d4d0c28725014fcab6635120197932a1 
SRCREV_copy="edeb9f37d4d0c28725014fcab6635120197932a1"
SRC_URI += "git://github.com/otiai10/copy;name=copy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/otiai10/copy"

# github.com/otiai10/curr v1.0.0
# [1] git ls-remote https://github.com/otiai10/curr 88e2f2cffa0b5f13e90ee963a321bd1b2f715561 
SRCREV_curr="88e2f2cffa0b5f13e90ee963a321bd1b2f715561"
SRC_URI += "git://github.com/otiai10/curr;name=curr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/otiai10/curr"

# github.com/otiai10/mint v1.3.2
# [1] git ls-remote https://github.com/otiai10/mint 3588d691480a831b1e78b776d3bccd9d5ce6461c 
SRCREV_mint="3588d691480a831b1e78b776d3bccd9d5ce6461c"
SRC_URI += "git://github.com/otiai10/mint;name=mint;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/otiai10/mint"

# github.com/pascaldekloe/goe v0.0.0-20180627143212-57f6aae5913c
# [1] git ls-remote https://github.com/pascaldekloe/goe 57f6aae5913c64c9bcae5dbdffd33365b5a7f138 
SRCREV_goe="57f6aae5913c64c9bcae5dbdffd33365b5a7f138"
SRC_URI += "git://github.com/pascaldekloe/goe;name=goe;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pascaldekloe/goe"

# github.com/paulmach/orb v0.1.3
# [1] git ls-remote https://github.com/paulmach/orb c6e407b203494d3b1edb9fd5cae4cf34a4ae0f29 
SRCREV_orb="c6e407b203494d3b1edb9fd5cae4cf34a4ae0f29"
SRC_URI += "git://github.com/paulmach/orb;name=orb;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/paulmach/orb"

# github.com/pborman/uuid v1.2.1
# [1] git ls-remote https://github.com/pborman/uuid 5b6091a6a160ee5ce12917b21ab96acec2a4fdc0 
SRCREV_uuid12="5b6091a6a160ee5ce12917b21ab96acec2a4fdc0"
SRC_URI += "git://github.com/pborman/uuid;name=uuid12;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pborman/uuid"

# github.com/pelletier/go-buffruneio v0.2.0
# [1] git ls-remote https://github.com/pelletier/go-buffruneio c37440a7cf42ac63b919c752ca73a85067e05992 
SRCREV_go-buffruneio="c37440a7cf42ac63b919c752ca73a85067e05992"
SRC_URI += "git://github.com/pelletier/go-buffruneio;name=go-buffruneio;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pelletier/go-buffruneio"

# github.com/pelletier/go-toml v1.9.4
# [1] git ls-remote https://github.com/pelletier/go-toml b8ba995eaaba4be30c8a8090bdfb4aa61af52054 
SRCREV_go-toml="b8ba995eaaba4be30c8a8090bdfb4aa61af52054"
SRC_URI += "git://github.com/pelletier/go-toml;name=go-toml;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pelletier/go-toml"

# github.com/peterbourgon/diskv v2.0.1+incompatible
# [1] git ls-remote https://github.com/peterbourgon/diskv 5f041e8faa004a95c88a202771f4cc3e991971e6 
SRCREV_diskv="5f041e8faa004a95c88a202771f4cc3e991971e6"
SRC_URI += "git://github.com/peterbourgon/diskv;name=diskv;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/peterbourgon/diskv"

# github.com/pierrec/lz4 v2.6.0+incompatible
# [1] git ls-remote https://github.com/pierrec/lz4 0e583d326e0ec6b9c1ad223188dc709af385408e 
SRCREV_lz4="0e583d326e0ec6b9c1ad223188dc709af385408e"
SRC_URI += "git://github.com/pierrec/lz4;name=lz4;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pierrec/lz4"

# github.com/pkg/errors v0.9.1
# [1] git ls-remote https://github.com/pkg/errors 614d223910a179a466c1767a985424175c39b465 
SRCREV_errors123="614d223910a179a466c1767a985424175c39b465"
SRC_URI += "git://github.com/pkg/errors;name=errors123;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pkg/errors"

# github.com/pkg/sftp v1.10.1
# [1] git ls-remote https://github.com/pkg/sftp 43d3a6e716b1ed42563b40666089f29a19c2ce9d 
SRCREV_sftp="43d3a6e716b1ed42563b40666089f29a19c2ce9d"
SRC_URI += "git://github.com/pkg/sftp;name=sftp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pkg/sftp"

# github.com/pmezard/go-difflib v1.0.0
# [1] git ls-remote https://github.com/pmezard/go-difflib c0b812dadcf4498dede02bb7f0c5c478be997e34 
SRCREV_go-difflib="c0b812dadcf4498dede02bb7f0c5c478be997e34"
SRC_URI += "git://github.com/pmezard/go-difflib;name=go-difflib;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pmezard/go-difflib"

# github.com/posener/complete v1.1.1
# [1] git ls-remote https://github.com/posener/complete 98eb9847f27ba2008d380a32c98be474dea55bdf 
SRCREV_complete="98eb9847f27ba2008d380a32c98be474dea55bdf"
SRC_URI += "git://github.com/posener/complete;name=complete;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/posener/complete"

# github.com/pquerna/cachecontrol v0.0.0-20171018203845-0dec1b30a021
# [1] git ls-remote https://github.com/pquerna/cachecontrol 0dec1b30a0215bb68605dfc568e8855066c9202d 
SRCREV_cachecontrol="0dec1b30a0215bb68605dfc568e8855066c9202d"
SRC_URI += "git://github.com/pquerna/cachecontrol;name=cachecontrol;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/pquerna/cachecontrol"

# github.com/prometheus/client_golang v1.11.0
# [1] git ls-remote https://github.com/prometheus/client_golang 9b6b6df74a146d5e700cd7205818ad6b2f0afec2 
SRCREV_client_golang="9b6b6df74a146d5e700cd7205818ad6b2f0afec2"
SRC_URI += "git://github.com/prometheus/client_golang;name=client_golang;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/client_golang"

# github.com/prometheus/client_model v0.2.0
# [1] git ls-remote https://github.com/prometheus/client_model f44e7adcba5ee54c8a94709e6fc300d83245f171 
SRCREV_client_model="f44e7adcba5ee54c8a94709e6fc300d83245f171"
SRC_URI += "git://github.com/prometheus/client_model;name=client_model;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/client_model"

# github.com/prometheus/common v0.26.0
# [1] git ls-remote https://github.com/prometheus/common 529a9a7d1e855d053e72af381608b7f89ac0e6e6 
SRCREV_common="529a9a7d1e855d053e72af381608b7f89ac0e6e6"
SRC_URI += "git://github.com/prometheus/common;name=common;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/common"

# github.com/prometheus/procfs v0.6.0
# [1] git ls-remote https://github.com/prometheus/procfs 3d15d641cf3611be0d06474548e5e41c3e514df9 
SRCREV_procfs="3d15d641cf3611be0d06474548e5e41c3e514df9"
SRC_URI += "git://github.com/prometheus/procfs;name=procfs;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/procfs"

# github.com/prometheus/tsdb v0.7.1
# [1] git ls-remote https://github.com/prometheus/tsdb 249a0812a512567b7278c767772d4bd7bdddefcd 
SRCREV_tsdb="249a0812a512567b7278c767772d4bd7bdddefcd"
SRC_URI += "git://github.com/prometheus/tsdb;name=tsdb;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/prometheus/tsdb"

# github.com/qri-io/starlib v0.4.2-0.20200213133954-ff2e8cd5ef8d
# [1] git ls-remote https://github.com/qri-io/starlib ff2e8cd5ef8d5cfec439238ec91bc1f03c84b306 
SRCREV_starlib="ff2e8cd5ef8d5cfec439238ec91bc1f03c84b306"
SRC_URI += "git://github.com/qri-io/starlib;name=starlib;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/qri-io/starlib"

# github.com/quobyte/api v0.1.8
# [1] git ls-remote https://github.com/quobyte/api 61b1aa26de01c522ca8a2c713443137c99760036 
SRCREV_api1="61b1aa26de01c522ca8a2c713443137c99760036"
SRC_URI += "git://github.com/quobyte/api;name=api1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/quobyte/api"

# github.com/rancher/dynamiclistener v0.3.1
# [1] git ls-remote https://github.com/rancher/dynamiclistener 43f9c3ae0a4fe7e689b2e2ed5a7064ed01ad8e64 
SRCREV_dynamiclistener="43f9c3ae0a4fe7e689b2e2ed5a7064ed01ad8e64"
SRC_URI += "git://github.com/rancher/dynamiclistener;name=dynamiclistener;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/dynamiclistener"

# github.com/rancher/lasso v0.0.0-20210616224652-fc3ebd901c08
# [1] git ls-remote https://github.com/rancher/lasso fc3ebd901c086dc8e4bfe2c07edf03c118572924 
SRCREV_lasso="fc3ebd901c086dc8e4bfe2c07edf03c118572924"
SRC_URI += "git://github.com/rancher/lasso;name=lasso;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/lasso"

# github.com/rancher/remotedialer v0.2.0
# [1] git ls-remote https://github.com/rancher/remotedialer 3d086baa0d95326b73f6f1d16286cc04fc856790 
SRCREV_remotedialer="3d086baa0d95326b73f6f1d16286cc04fc856790"
SRC_URI += "git://github.com/rancher/remotedialer;name=remotedialer;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/remotedialer"

# github.com/rancher/wharfie v0.5.1
# [1] git ls-remote https://github.com/rancher/wharfie 80cc0b0ce983af2d75be7846e006d69fa5d64570 
SRCREV_wharfie="80cc0b0ce983af2d75be7846e006d69fa5d64570"
SRC_URI += "git://github.com/rancher/wharfie;name=wharfie;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/wharfie"

# github.com/rancher/wrangler v0.8.11-0.20220211163748-d5a8ee98be5f
# [1] git ls-remote https://github.com/rancher/wrangler d5a8ee98be5f6eb429253d080017bd6dc691db97 
SRCREV_wrangler="d5a8ee98be5f6eb429253d080017bd6dc691db97"
SRC_URI += "git://github.com/rancher/wrangler;name=wrangler;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rancher/wrangler"

# github.com/remyoudompheng/bigfft v0.0.0-20170806203942-52369c62f446
# [1] git ls-remote https://github.com/remyoudompheng/bigfft 52369c62f4463a21c8ff8531194c5526322b8521 
SRCREV_bigfft="52369c62f4463a21c8ff8531194c5526322b8521"
SRC_URI += "git://github.com/remyoudompheng/bigfft;name=bigfft;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/remyoudompheng/bigfft"

# github.com/robfig/cron/v3 v3.0.1
# [1] git ls-remote https://github.com/robfig/cron ccba498c397bb90a9c84945bbb0f7af2d72b6309 
SRCREV_v31="ccba498c397bb90a9c84945bbb0f7af2d72b6309"
SRC_URI += "git://github.com/robfig/cron;name=v31;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/robfig/cron/v3"

# github.com/rogpeppe/fastuuid v1.2.0
# [1] git ls-remote https://github.com/rogpeppe/fastuuid 10c3923834d38e951ae8f627bfec2dc632c5b6cb 
SRCREV_fastuuid="10c3923834d38e951ae8f627bfec2dc632c5b6cb"
SRC_URI += "git://github.com/rogpeppe/fastuuid;name=fastuuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rogpeppe/fastuuid"

# github.com/rogpeppe/go-internal v1.3.0
# [1] git ls-remote https://github.com/rogpeppe/go-internal c41aae108fba1a0e55d440c3046043e1c32c4f9a 
SRCREV_go-internal="c41aae108fba1a0e55d440c3046043e1c32c4f9a"
SRC_URI += "git://github.com/rogpeppe/go-internal;name=go-internal;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rogpeppe/go-internal"

# github.com/rootless-containers/rootlesskit v0.14.5
# [1] git ls-remote https://github.com/rootless-containers/rootlesskit e2d540ea3318e9e72ce2fb00734a0ac102efe733 
SRCREV_rootlesskit="e2d540ea3318e9e72ce2fb00734a0ac102efe733"
SRC_URI += "git://github.com/rootless-containers/rootlesskit;name=rootlesskit;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rootless-containers/rootlesskit"

# github.com/rs/xid v1.3.0
# [1] git ls-remote https://github.com/rs/xid efa678f304ab65d6d57eedcb086798381ae22206 
SRCREV_xid="efa678f304ab65d6d57eedcb086798381ae22206"
SRC_URI += "git://github.com/rs/xid;name=xid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rs/xid"

# github.com/rubiojr/go-vhd v0.0.0-20200706105327-02e210299021
# [1] git ls-remote https://github.com/rubiojr/go-vhd 02e2102990218160c1cb608a3e9679312a3b8425 
SRCREV_go-vhd="02e2102990218160c1cb608a3e9679312a3b8425"
SRC_URI += "git://github.com/rubiojr/go-vhd;name=go-vhd;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rubiojr/go-vhd"

# github.com/russross/blackfriday v1.5.2
# [1] git ls-remote https://github.com/russross/blackfriday 05f3235734ad95d0016f6a23902f06461fcf567a 
SRCREV_blackfriday="05f3235734ad95d0016f6a23902f06461fcf567a"
SRC_URI += "git://github.com/russross/blackfriday;name=blackfriday;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/russross/blackfriday"

# github.com/russross/blackfriday/v2 v2.1.0
# [1] git ls-remote https://github.com/russross/blackfriday 4c9bf9512682b995722660a4196c0013228e2049 
SRCREV_v21234="4c9bf9512682b995722660a4196c0013228e2049"
SRC_URI += "git://github.com/russross/blackfriday;name=v21234;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/russross/blackfriday/v2"

# github.com/ryanuber/columnize v0.0.0-20160712163229-9b3edd62028f
# [1] git ls-remote https://github.com/ryanuber/columnize 9b3edd62028f107d7cabb19353292afd29311a4e 
SRCREV_columnize="9b3edd62028f107d7cabb19353292afd29311a4e"
SRC_URI += "git://github.com/ryanuber/columnize;name=columnize;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ryanuber/columnize"

# github.com/safchain/ethtool v0.0.0-20190326074333-42ed695e3de8
# [1] git ls-remote https://github.com/safchain/ethtool 42ed695e3de80b9d695f280295fd7994639f209d 
SRCREV_ethtool1="42ed695e3de80b9d695f280295fd7994639f209d"
SRC_URI += "git://github.com/safchain/ethtool;name=ethtool1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/safchain/ethtool"

# github.com/satori/go.uuid v1.2.0
# [1] git ls-remote https://github.com/satori/go.uuid fe3bd84a0754cc4deb35c1398cd0ebd23f1d8a41 
SRCREV_go.uuid="fe3bd84a0754cc4deb35c1398cd0ebd23f1d8a41"
SRC_URI += "git://github.com/satori/go.uuid;name=go.uuid;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/satori/go.uuid"

# github.com/sean-/seed v0.0.0-20170313163322-e2103e2c3529
# [1] git ls-remote https://github.com/sean-/seed e2103e2c35297fb7e17febb81e49b312087a2372 
SRCREV_seed="e2103e2c35297fb7e17febb81e49b312087a2372"
SRC_URI += "git://github.com/sean-/seed;name=seed;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/sean-/seed"

# github.com/seccomp/libseccomp-golang v0.9.1
# [1] git ls-remote https://github.com/seccomp/libseccomp-golang 8107a3debc22fba7e6e48099eb3e1090bf6c78ba 
SRCREV_libseccomp-golang="8107a3debc22fba7e6e48099eb3e1090bf6c78ba"
SRC_URI += "git://github.com/seccomp/libseccomp-golang;name=libseccomp-golang;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/seccomp/libseccomp-golang"

# github.com/sergi/go-diff v1.1.0
# [1] git ls-remote https://github.com/sergi/go-diff 6a0dfe7dd071f7a6a16e06409e39d73bca00f2d4 
SRCREV_go-diff="6a0dfe7dd071f7a6a16e06409e39d73bca00f2d4"
SRC_URI += "git://github.com/sergi/go-diff;name=go-diff;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/sergi/go-diff"

# github.com/shurcooL/sanitized_anchor_name v1.0.0
# [1] git ls-remote https://github.com/shurcooL/sanitized_anchor_name 7bfe4c7ecddb3666a94b053b422cdd8f5aaa3615 
SRCREV_sanitized_anchor_name="7bfe4c7ecddb3666a94b053b422cdd8f5aaa3615"
SRC_URI += "git://github.com/shurcooL/sanitized_anchor_name;name=sanitized_anchor_name;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/shurcooL/sanitized_anchor_name"

# github.com/sirupsen/logrus v1.8.1
# [1] git ls-remote https://github.com/sirupsen/logrus bdc0db8ead3853c56b7cd1ac2ba4e11b47d7da6b 
SRCREV_logrus="bdc0db8ead3853c56b7cd1ac2ba4e11b47d7da6b"
SRC_URI += "git://github.com/sirupsen/logrus;name=logrus;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/sirupsen/logrus"

# github.com/smartystreets/assertions v1.1.0
# [1] git ls-remote https://github.com/smartystreets/assertions b40663cb802db13783b76a18589060864ab8df1f 
SRCREV_assertions="b40663cb802db13783b76a18589060864ab8df1f"
SRC_URI += "git://github.com/smartystreets/assertions;name=assertions;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/smartystreets/assertions"

# github.com/smartystreets/goconvey v1.6.4
# [1] git ls-remote https://github.com/smartystreets/goconvey 505e419363375c0dc132d3ac02632a4ee32199ca 
SRCREV_goconvey="505e419363375c0dc132d3ac02632a4ee32199ca"
SRC_URI += "git://github.com/smartystreets/goconvey;name=goconvey;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/smartystreets/goconvey"

# github.com/soheilhy/cmux v0.1.5
# [1] git ls-remote https://github.com/soheilhy/cmux 5ec6847320e53b5fee0ab9a4757b56625a946c85 
SRCREV_cmux="5ec6847320e53b5fee0ab9a4757b56625a946c85"
SRC_URI += "git://github.com/soheilhy/cmux;name=cmux;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/soheilhy/cmux"

# github.com/songgao/water v0.0.0-20200317203138-2b4b6d7c09d8
# [1] git ls-remote https://github.com/songgao/water 2b4b6d7c09d80835e5f13f6b040d69f00a158b24 
SRCREV_water="2b4b6d7c09d80835e5f13f6b040d69f00a158b24"
SRC_URI += "git://github.com/songgao/water;name=water;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/songgao/water"

# github.com/spaolacci/murmur3 v0.0.0-20180118202830-f09979ecbc72
# [1] git ls-remote https://github.com/spaolacci/murmur3 f09979ecbc725b9e6d41a297405f65e7e8804acc 
SRCREV_murmur3="f09979ecbc725b9e6d41a297405f65e7e8804acc"
SRC_URI += "git://github.com/spaolacci/murmur3;name=murmur3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spaolacci/murmur3"

# github.com/spf13/afero v1.6.0
# [1] git ls-remote https://github.com/spf13/afero bc94f58beda5dbff6f74599fcb1f1717c5b1c111 
SRCREV_afero="bc94f58beda5dbff6f74599fcb1f1717c5b1c111"
SRC_URI += "git://github.com/spf13/afero;name=afero;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/afero"

# github.com/spf13/cast v1.3.1
# [1] git ls-remote https://github.com/spf13/cast 1ffadf551085444af981432dd0f6d1160c11ec64 
SRCREV_cast="1ffadf551085444af981432dd0f6d1160c11ec64"
SRC_URI += "git://github.com/spf13/cast;name=cast;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/cast"

# github.com/spf13/cobra v1.2.1
# [1] git ls-remote https://github.com/spf13/cobra de187e874d1ca382320088f8f6d76333408e5c2e 
SRCREV_cobra="de187e874d1ca382320088f8f6d76333408e5c2e"
SRC_URI += "git://github.com/spf13/cobra;name=cobra;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/cobra"

# github.com/spf13/jwalterweatherman v1.1.0
# [1] git ls-remote https://github.com/spf13/jwalterweatherman 94f6ae3ed3bceceafa716478c5fbf8d29ca601a1 
SRCREV_jwalterweatherman="94f6ae3ed3bceceafa716478c5fbf8d29ca601a1"
SRC_URI += "git://github.com/spf13/jwalterweatherman;name=jwalterweatherman;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/jwalterweatherman"

# github.com/spf13/pflag v1.0.5
# [1] git ls-remote https://github.com/spf13/pflag 2e9d26c8c37aae03e3f9d4e90b7116f5accb7cab 
SRCREV_pflag="2e9d26c8c37aae03e3f9d4e90b7116f5accb7cab"
SRC_URI += "git://github.com/spf13/pflag;name=pflag;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/pflag"

# github.com/spf13/viper v1.8.1
# [1] git ls-remote https://github.com/spf13/viper 50df275b9f7ebeab30e4859dc9bb58b2535d40d0 
SRCREV_viper="50df275b9f7ebeab30e4859dc9bb58b2535d40d0"
SRC_URI += "git://github.com/spf13/viper;name=viper;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/spf13/viper"

# github.com/stefanberger/go-pkcs11uri v0.0.0-20201008174630-78d3cae3a980
# [1] git ls-remote https://github.com/stefanberger/go-pkcs11uri 78d3cae3a9805d89aa4fa80a362ca944c89a1b99 
SRCREV_go-pkcs11uri="78d3cae3a9805d89aa4fa80a362ca944c89a1b99"
SRC_URI += "git://github.com/stefanberger/go-pkcs11uri;name=go-pkcs11uri;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stefanberger/go-pkcs11uri"

# github.com/stoewer/go-strcase v1.2.0
# [1] git ls-remote https://github.com/stoewer/go-strcase 7962b205553802087345c0b4c74d57b65236f676 
SRCREV_go-strcase="7962b205553802087345c0b4c74d57b65236f676"
SRC_URI += "git://github.com/stoewer/go-strcase;name=go-strcase;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stoewer/go-strcase"

# github.com/storageos/go-api v2.2.0+incompatible
# [1] git ls-remote https://github.com/storageos/go-api d6e6bab2519238b8a582cabd2f4a71cca81963aa 
SRCREV_go-api="d6e6bab2519238b8a582cabd2f4a71cca81963aa"
SRC_URI += "git://github.com/storageos/go-api;name=go-api;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/storageos/go-api"

# github.com/stretchr/objx v0.2.0
# [1] git ls-remote https://github.com/stretchr/objx ea4fe68685ee0d3cee7032121851b57e7494e8ea 
SRCREV_objx="ea4fe68685ee0d3cee7032121851b57e7494e8ea"
SRC_URI += "git://github.com/stretchr/objx;name=objx;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stretchr/objx"

# github.com/stretchr/testify v1.7.0
# [1] git ls-remote https://github.com/stretchr/testify acba37e5db06f0093b465a7d47822bf13644b66c 
SRCREV_testify1="acba37e5db06f0093b465a7d47822bf13644b66c"
SRC_URI += "git://github.com/stretchr/testify;name=testify1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/stretchr/testify"

# github.com/subosito/gotenv v1.2.0
# [1] git ls-remote https://github.com/subosito/gotenv 4611354b6b3c13ad584fed71faf1f970aab511c3 
SRCREV_gotenv="4611354b6b3c13ad584fed71faf1f970aab511c3"
SRC_URI += "git://github.com/subosito/gotenv;name=gotenv;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/subosito/gotenv"

# github.com/syndtr/gocapability v0.0.0-20200815063812-42c35b437635
# [1] git ls-remote https://github.com/syndtr/gocapability 42c35b4376354fd554efc7ad35e0b7f94e3a0ffb 
SRCREV_gocapability="42c35b4376354fd554efc7ad35e0b7f94e3a0ffb"
SRC_URI += "git://github.com/syndtr/gocapability;name=gocapability;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/syndtr/gocapability"

# github.com/tchap/go-patricia v2.3.0+incompatible
# [1] git ls-remote https://github.com/tchap/go-patricia a7f0089c6f496e8e70402f61733606daa326cac5 
SRCREV_go-patricia="a7f0089c6f496e8e70402f61733606daa326cac5"
SRC_URI += "git://github.com/tchap/go-patricia;name=go-patricia;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tchap/go-patricia"

# github.com/tencentcloud/tencentcloud-sdk-go v1.0.67
# [1] git ls-remote https://github.com/tencentcloud/tencentcloud-sdk-go d1f36c65d42b2276260adba712fcd48fa20f2ad3 
SRCREV_tencentcloud-sdk-go="d1f36c65d42b2276260adba712fcd48fa20f2ad3"
SRC_URI += "git://github.com/tencentcloud/tencentcloud-sdk-go;name=tencentcloud-sdk-go;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tencentcloud/tencentcloud-sdk-go"

# github.com/tidwall/pretty v1.0.0
# [1] git ls-remote https://github.com/tidwall/pretty 1166b9ac2b65e46a43d8618d30d1554f4652d49b 
SRCREV_pretty12="1166b9ac2b65e46a43d8618d30d1554f4652d49b"
SRC_URI += "git://github.com/tidwall/pretty;name=pretty12;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tidwall/pretty"

# github.com/tmc/grpc-websocket-proxy v0.0.0-20201229170055-e5319fda7802
# [1] git ls-remote https://github.com/tmc/grpc-websocket-proxy e5319fda780223b9d4d06dba2059a26ebff67b8a 
SRCREV_grpc-websocket-proxy="e5319fda780223b9d4d06dba2059a26ebff67b8a"
SRC_URI += "git://github.com/tmc/grpc-websocket-proxy;name=grpc-websocket-proxy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/tmc/grpc-websocket-proxy"

# github.com/u-root/u-root v7.0.0+incompatible
# [1] git ls-remote https://github.com/u-root/u-root 5e45509ddd2c688178bff8fc796b028f2a752ecd 
SRCREV_u-root="5e45509ddd2c688178bff8fc796b028f2a752ecd"
SRC_URI += "git://github.com/u-root/u-root;name=u-root;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/u-root/u-root"

# github.com/ugorji/go v1.1.4
# [1] git ls-remote https://github.com/ugorji/go 2adff0894ba3bc2eeb9f9aea45fefd49802e1a13 
SRCREV_go123="2adff0894ba3bc2eeb9f9aea45fefd49802e1a13"
SRC_URI += "git://github.com/ugorji/go;name=go123;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/ugorji/go"

# github.com/urfave/cli v1.22.4
# [1] git ls-remote https://github.com/urfave/cli 053ba9dd02d2bfb768da2c1c50370c59d41dc04b 
SRCREV_cli12="053ba9dd02d2bfb768da2c1c50370c59d41dc04b"
SRC_URI += "git://github.com/urfave/cli;name=cli12;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/urfave/cli"

# github.com/urfave/cli/v2 v2.3.0
# [1] git ls-remote https://github.com/urfave/cli 09ac54c2f97f4249282baf266c54a09fab1bef58 
SRCREV_v212345="09ac54c2f97f4249282baf266c54a09fab1bef58"
SRC_URI += "git://github.com/urfave/cli;name=v212345;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/urfave/cli/v2"

# github.com/urfave/negroni v1.0.0
# [1] git ls-remote https://github.com/urfave/negroni c6a59be0ce122566695fbd5e48a77f8f10c8a63a 
SRCREV_negroni="c6a59be0ce122566695fbd5e48a77f8f10c8a63a"
SRC_URI += "git://github.com/urfave/negroni;name=negroni;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/urfave/negroni"

# github.com/vbatts/tar-split v0.11.2
# [1] git ls-remote https://github.com/vbatts/tar-split 6f35a43a158e8592b08db7e910de4236256df15f 
SRCREV_tar-split="6f35a43a158e8592b08db7e910de4236256df15f"
SRC_URI += "git://github.com/vbatts/tar-split;name=tar-split;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vbatts/tar-split"

# github.com/vektah/gqlparser v1.1.2
# [1] git ls-remote https://github.com/vektah/gqlparser 05741cdb0871330d8bc980d4afd21ab34eceee83 
SRCREV_gqlparser="05741cdb0871330d8bc980d4afd21ab34eceee83"
SRC_URI += "git://github.com/vektah/gqlparser;name=gqlparser;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vektah/gqlparser"

# github.com/vishvananda/netlink v1.1.1-0.20201029203352-d40f9887b852
# [1] git ls-remote https://github.com/vishvananda/netlink d40f9887b852ec4ce633f2a46734422c87fc8336 
SRCREV_netlink1="d40f9887b852ec4ce633f2a46734422c87fc8336"
SRC_URI += "git://github.com/vishvananda/netlink;name=netlink1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vishvananda/netlink"

# github.com/vishvananda/netns v0.0.0-20210104183010-2eb08e3e575f
# [1] git ls-remote https://github.com/vishvananda/netns 2eb08e3e575f00733a612d25cc5d7470f8db6f35 
SRCREV_netns="2eb08e3e575f00733a612d25cc5d7470f8db6f35"
SRC_URI += "git://github.com/vishvananda/netns;name=netns;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vishvananda/netns"

# github.com/vmware/govmomi v0.20.3
# [1] git ls-remote https://github.com/vmware/govmomi df148c315eaf6a84f23771aca1bce8a5e6dc6de9 
SRCREV_govmomi="df148c315eaf6a84f23771aca1bce8a5e6dc6de9"
SRC_URI += "git://github.com/vmware/govmomi;name=govmomi;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/vmware/govmomi"

# github.com/willf/bitset v1.1.11
# [1] git ls-remote https://github.com/willf/bitset 559910e8471e48d76d9e5a1ba15842dee77ad45d 
SRCREV_bitset1="559910e8471e48d76d9e5a1ba15842dee77ad45d"
SRC_URI += "git://github.com/willf/bitset;name=bitset1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/willf/bitset"

# github.com/xiang90/probing v0.0.0-20190116061207-43a291ad63a2
# [1] git ls-remote https://github.com/xiang90/probing 43a291ad63a214a207fefbf03c7d9d78b703162b 
SRCREV_probing="43a291ad63a214a207fefbf03c7d9d78b703162b"
SRC_URI += "git://github.com/xiang90/probing;name=probing;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/xiang90/probing"

# github.com/xlab/treeprint v0.0.0-20181112141820-a009c3971eca
# [1] git ls-remote https://github.com/xlab/treeprint a009c3971eca89777614839eb7f69abed3ea3959 
SRCREV_treeprint="a009c3971eca89777614839eb7f69abed3ea3959"
SRC_URI += "git://github.com/xlab/treeprint;name=treeprint;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/xlab/treeprint"

# github.com/xordataexchange/crypt v0.0.3-0.20170626215501-b2862e3d0a77
# [1] git ls-remote https://github.com/xordataexchange/crypt b2862e3d0a775f18c7cfe02273500ae307b61218 
SRCREV_crypt1="b2862e3d0a775f18c7cfe02273500ae307b61218"
SRC_URI += "git://github.com/xordataexchange/crypt;name=crypt1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/xordataexchange/crypt"

# github.com/yuin/goldmark v1.4.1
# [1] git ls-remote https://github.com/yuin/goldmark 829d874034a5048e1a5c6354dcd8b40e1e41c3a2 
SRCREV_goldmark="829d874034a5048e1a5c6354dcd8b40e1e41c3a2"
SRC_URI += "git://github.com/yuin/goldmark;name=goldmark;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/yuin/goldmark"

# go.etcd.io/bbolt v1.3.6
# [1] git ls-remote https://github.com/etcd-io/bbolt 32406da58029624a55b1ad25b8ea6f0582021dd6 
SRCREV_bbolt1="32406da58029624a55b1ad25b8ea6f0582021dd6"
SRC_URI += "git://github.com/etcd-io/bbolt;name=bbolt1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.etcd.io/bbolt"

# go.etcd.io/etcd v0.5.0-alpha.5.0.20200910180754-dd1b699fc489
# [1] git ls-remote https://github.com/etcd-io/etcd dd1b699fc4895de8cc23c3cac5a428c37eee384a 
SRCREV_etcd1="dd1b699fc4895de8cc23c3cac5a428c37eee384a"
SRC_URI += "git://github.com/etcd-io/etcd;name=etcd1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.etcd.io/etcd"

# github.com/k3s-io/etcd/api/v3 v3.5.1-k3s1
# [1] git ls-remote https://github.com/k3s-io/etcd 643f36c2206cf25c8103cccc4a5e036092ee51d0 
SRCREV_v312="643f36c2206cf25c8103cccc4a5e036092ee51d0"
SRC_URI += "git://github.com/k3s-io/etcd;name=v312;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/etcd/api/v3"

# go.etcd.io/etcd/client/pkg/v3 v3.5.1
# [1] git ls-remote https://github.com/etcd-io/etcd 41e93a0e15df55891f00a7c5630363b5f7c6a62e 
SRCREV_v3123="41e93a0e15df55891f00a7c5630363b5f7c6a62e"
SRC_URI += "git://github.com/etcd-io/etcd;name=v3123;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/etcd-io/etcd/client/pkg/v3"

# go.etcd.io/etcd/client/v2 v2.305.1
# [1] git ls-remote https://github.com/etcd-io/etcd 71bba3c761b0078c81c2b39781ec74853c458303 
SRCREV_v2123456="71bba3c761b0078c81c2b39781ec74853c458303"
SRC_URI += "git://github.com/etcd-io/etcd;name=v2123456;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/etcd-io/etcd/client/v2"

# go.etcd.io/etcd/pkg/v3 v3.5.1
# [1] git ls-remote https://github.com/etcd-io/etcd 41e93a0e15df55891f00a7c5630363b5f7c6a62e 
SRCREV_v3123456="41e93a0e15df55891f00a7c5630363b5f7c6a62e"
SRC_URI += "git://github.com/etcd-io/etcd;name=v3123456;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/etcd-io/etcd/client/pkg/v3"

# [2] failed: fatal: repository 'https://go.mongodb.org/' not found
#     site; go.mongodb.org/mongo-driver
# git ls-remote https://go.mongodb.org v1.1.2 
# SRCREV_mongo-driver="deadbeef"
# SRC_URI += "git://go.mongodb.org;name=mongo-driver;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.mongodb.org/mongo-driver"

# go.mozilla.org/pkcs7 v0.0.0-20200128120323-432b2356ecb1
# [1] git ls-remote https://github.com/mozilla-services/pkcs7 432b2356ecb18209c1cec25680b8a23632794f21 
SRCREV_pkcs7="432b2356ecb18209c1cec25680b8a23632794f21"
SRC_URI += "git://github.com/mozilla-services/pkcs7;name=pkcs7;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.mozilla.org/pkcs7"

# go.opencensus.io v0.23.0
# [1] git ls-remote https://github.com/census-instrumentation/opencensus-go 49838f207d61097fc0ebb8aeef306913388376ca 
SRCREV_go.opencensus.io="49838f207d61097fc0ebb8aeef306913388376ca"
SRC_URI += "git://github.com/census-instrumentation/opencensus-go;name=go.opencensus.io;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opencensus.io"

# go.opentelemetry.io/contrib v0.20.0
# [1] git ls-remote https://github.com/open-telemetry/opentelemetry-go-contrib 26f8fdc236a8b3dab4abbb0c2f13f1a37f47fde6 
SRCREV_contrib="26f8fdc236a8b3dab4abbb0c2f13f1a37f47fde6"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go-contrib;name=contrib;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/contrib"

# go.opentelemetry.io/otel v0.20.0
# [1] git ls-remote https://github.com/open-telemetry/opentelemetry-go 842e1a46712b10d9ab5934254f81787d957f8d21 
SRCREV_otel="842e1a46712b10d9ab5934254f81787d957f8d21"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-go;name=otel;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.opentelemetry.io/otel"

# go.opentelemetry.io/proto/otlp v0.7.0
# [1] git ls-remote https://github.com/open-telemetry/opentelemetry-proto-go 5439eb8c2edea5f9fcbe1ea9993624a7ad74215c 
SRCREV_otlp1="5439eb8c2edea5f9fcbe1ea9993624a7ad74215c"
SRC_URI += "git://github.com/open-telemetry/opentelemetry-proto-go;name=otlp1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/open-telemetry/opentelemetry-proto-go/otlp"

# go.starlark.net v0.0.0-20200306205701-8dd3e2ee1dd5
# [1] git ls-remote https://github.com/google/starlark-go 8dd3e2ee1dd5d034baada4c7b4fcf231294a1013 
SRCREV_go.starlark.net="8dd3e2ee1dd5d034baada4c7b4fcf231294a1013"
SRC_URI += "git://github.com/google/starlark-go;name=go.starlark.net;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/google/starlark-go"

# go.uber.org/atomic v1.7.0
# [1] git ls-remote https://github.com/uber-go/atomic 3f685f518c6a22050970a225fdf0097079f525f8 
SRCREV_atomic="3f685f518c6a22050970a225fdf0097079f525f8"
SRC_URI += "git://github.com/uber-go/atomic;name=atomic;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/atomic"

# go.uber.org/goleak v1.1.10
# [1] git ls-remote https://github.com/uber-go/goleak 8186b793a375782d05df2748849e26b541b19ace 
SRCREV_goleak="8186b793a375782d05df2748849e26b541b19ace"
SRC_URI += "git://github.com/uber-go/goleak;name=goleak;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/goleak"

# go.uber.org/multierr v1.6.0
# [1] git ls-remote https://github.com/uber-go/multierr aa4dba30678ced01398aaed615ad69f3bb35de3a 
SRCREV_multierr="aa4dba30678ced01398aaed615ad69f3bb35de3a"
SRC_URI += "git://github.com/uber-go/multierr;name=multierr;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/multierr"

# go.uber.org/zap v1.17.0
# [1] git ls-remote https://github.com/uber-go/zap 2908d3000567b86f0b7f1e99cc6bc5c9f30d43a0 
SRCREV_zap="2908d3000567b86f0b7f1e99cc6bc5c9f30d43a0"
SRC_URI += "git://github.com/uber-go/zap;name=zap;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/go.uber.org/zap"

# golang.org/x/crypto v0.0.0-20210220033148-5ea612d1eb83
# [1] git ls-remote https://github.com/golang/crypto 5ea612d1eb830b38bc4e914e37f55311eb58adce 
SRCREV_crypto="5ea612d1eb830b38bc4e914e37f55311eb58adce"
SRC_URI += "git://github.com/golang/crypto;name=crypto;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/crypto"

# golang.org/x/exp v0.0.0-20210220032938-85be41e4509f
# [1] git ls-remote https://github.com/golang/exp 85be41e4509f417cbf99006a027aef75deb8afd1 
SRCREV_exp="85be41e4509f417cbf99006a027aef75deb8afd1"
SRC_URI += "git://github.com/golang/exp;name=exp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/exp"

# golang.org/x/image v0.0.0-20190802002840-cff245a6509b
# [1] git ls-remote https://github.com/golang/image cff245a6509b8c4de022d0d5b9037c503c5989d6 
SRCREV_image="cff245a6509b8c4de022d0d5b9037c503c5989d6"
SRC_URI += "git://github.com/golang/image;name=image;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/image"

# golang.org/x/lint v0.0.0-20210508222113-6edffad5e616
# [1] git ls-remote https://github.com/golang/lint 6edffad5e6160f5949cdefc81710b2706fbcd4f6 
SRCREV_lint="6edffad5e6160f5949cdefc81710b2706fbcd4f6"
SRC_URI += "git://github.com/golang/lint;name=lint;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/lint"

# golang.org/x/mobile v0.0.0-20201217150744-e6ae53a27f4f
# [1] git ls-remote https://github.com/golang/mobile e6ae53a27f4fd7cfa2943f2ae47b96cba8eb01c9 
SRCREV_mobile="e6ae53a27f4fd7cfa2943f2ae47b96cba8eb01c9"
SRC_URI += "git://github.com/golang/mobile;name=mobile;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/mobile"

# golang.org/x/mod v0.5.1
# [1] git ls-remote https://github.com/golang/mod 49f84bccfd3469cb3095201f7855641bcc8eb49a 
SRCREV_mod="49f84bccfd3469cb3095201f7855641bcc8eb49a"
SRC_URI += "git://github.com/golang/mod;name=mod;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/mod"

# golang.org/x/net v0.0.0-20210405180319-a5a99cb37ef4
# [1] git ls-remote https://github.com/golang/net a5a99cb37ef4b68617775ab669177656090ab396 
SRCREV_net="a5a99cb37ef4b68617775ab669177656090ab396"
SRC_URI += "git://github.com/golang/net;name=net;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/net"

# golang.org/x/oauth2 v0.0.0-20211104180415-d3ed0bb246c8
# [1] git ls-remote https://github.com/golang/oauth2 d3ed0bb246c8d3c75b63937d9a5eecff9c74d7fe 
SRCREV_oauth2="d3ed0bb246c8d3c75b63937d9a5eecff9c74d7fe"
SRC_URI += "git://github.com/golang/oauth2;name=oauth2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/oauth2"

# golang.org/x/sync v0.0.0-20210220032951-036812b2e83c
# [1] git ls-remote https://github.com/golang/sync 036812b2e83c0ddf193dd5a34e034151da389d09 
SRCREV_sync="036812b2e83c0ddf193dd5a34e034151da389d09"
SRC_URI += "git://github.com/golang/sync;name=sync;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/sync"

# golang.org/x/sys v0.0.0-20210831042530-f4d43177bf5e
# [1] git ls-remote https://github.com/golang/sys f4d43177bf5e2ee98617956e417d0555d4b69c17 
SRCREV_sys="f4d43177bf5e2ee98617956e417d0555d4b69c17"
SRC_URI += "git://github.com/golang/sys;name=sys;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/sys"

# golang.org/x/term v0.0.0-20210220032956-6a3ed077a48d
# [1] git ls-remote https://github.com/golang/term 6a3ed077a48de71621ad530f9078fffa0bc0ce32 
SRCREV_term1="6a3ed077a48de71621ad530f9078fffa0bc0ce32"
SRC_URI += "git://github.com/golang/term;name=term1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/term"

# golang.org/x/text v0.3.7
# [1] git ls-remote https://github.com/golang/text 3cd4007149f3f883d229d707172ed356727aae99 
SRCREV_text1="3cd4007149f3f883d229d707172ed356727aae99"
SRC_URI += "git://github.com/golang/text;name=text1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/text"

# golang.org/x/time v0.0.0-20210723032227-1f47c861a9ac
# [1] git ls-remote https://github.com/golang/time 1f47c861a9ac5a6e7645609f91b895398ff31642 
SRCREV_time="1f47c861a9ac5a6e7645609f91b895398ff31642"
SRC_URI += "git://github.com/golang/time;name=time;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/time"

# golang.org/x/tools v0.1.8
# [1] git ls-remote https://github.com/golang/tools e212aff8fd146c44ddb0167c1dfbd5531d6c9213 
SRCREV_tools="e212aff8fd146c44ddb0167c1dfbd5531d6c9213"
SRC_URI += "git://github.com/golang/tools;name=tools;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/tools"

# golang.org/x/xerrors v0.0.0-20200804184101-5ec99f83aff1
# [1] git ls-remote https://github.com/golang/xerrors 5ec99f83aff198f5fbd629d6c8d8eb38a04218ca 
SRCREV_xerrors="5ec99f83aff198f5fbd629d6c8d8eb38a04218ca"
SRC_URI += "git://github.com/golang/xerrors;name=xerrors;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.org/x/xerrors"

# [2] failed: fatal: repository 'https://git.zx2c4.com/' not found
#     site; golang.zx2c4.com/go118/netip
# git ls-remote https://git.zx2c4.com a4a02eeacf9d 
# SRCREV_netip="deadbeef"
# SRC_URI += "git://git.zx2c4.com;name=netip;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.zx2c4.com/go118/netip"

# golang.zx2c4.com/wintun v0.0.0-20211104114900-415007cec224
# [1] git ls-remote https://git.zx2c4.com/wintun-go 415007cec224e00ca8633a5d70c258cf9ab0cddd 
SRCREV_wintun="415007cec224e00ca8633a5d70c258cf9ab0cddd"
SRC_URI += "git://git.zx2c4.com/wintun-go;name=wintun;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.zx2c4.com/wintun"

# golang.zx2c4.com/wireguard v0.0.0-20220117163742-e0b8f11489c5
# [1] git ls-remote https://git.zx2c4.com/wireguard-go e0b8f11489c57cbb38b12ae446cf41c4df6ac553 
SRCREV_wireguard="e0b8f11489c57cbb38b12ae446cf41c4df6ac553"
SRC_URI += "git://git.zx2c4.com/wireguard-go;name=wireguard;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.zx2c4.com/wireguard"

# golang.zx2c4.com/wireguard/wgctrl v0.0.0-20211230205640-daad0b7ba671
# [1] git ls-remote https://github.com/WireGuard/wgctrl-go daad0b7ba671c0e628de07c6d16d24dbd0d8a55e 
SRCREV_wgctrl="daad0b7ba671c0e628de07c6d16d24dbd0d8a55e"
SRC_URI += "git://github.com/WireGuard/wgctrl-go;name=wgctrl;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/golang.zx2c4.com/wireguard/wgctrl"

# gonum.org/v1/gonum v0.6.2
# [1] git ls-remote https://github.com/gonum/gonum d85700d137aa397729110bf2a38ada165a5aa4f9 
SRCREV_gonum="d85700d137aa397729110bf2a38ada165a5aa4f9"
SRC_URI += "git://github.com/gonum/gonum;name=gonum;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gonum/gonum"

# gonum.org/v1/netlib v0.0.0-20190331212654-76723241ea4e
# [1] git ls-remote https://github.com/gonum/netlib 76723241ea4ea9096177178f67ff221166249992 
SRCREV_netlib="76723241ea4ea9096177178f67ff221166249992"
SRC_URI += "git://github.com/gonum/netlib;name=netlib;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gonum/netlib"

# gonum.org/v1/plot v0.0.0-20190515093506-e2840ee46a6b
# [1] git ls-remote https://github.com/gonum/plot e2840ee46a6b612972d746f9fea9920d329a0605 
SRCREV_plot="e2840ee46a6b612972d746f9fea9920d329a0605"
SRC_URI += "git://github.com/gonum/plot;name=plot;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gonum/plot"

# google.golang.org/api v0.57.0
# [1] git ls-remote https://github.com/googleapis/google-api-go-client 5dffc2b13eedc703d5e81c47bc3d2029a48203cb 
SRCREV_api12="5dffc2b13eedc703d5e81c47bc3d2029a48203cb"
SRC_URI += "git://github.com/googleapis/google-api-go-client;name=api12;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/api"

# google.golang.org/appengine v1.6.7
# [1] git ls-remote https://github.com/golang/appengine 5d1c1d03f8703c2e81478d9a30e9afa2d3e4bd8a 
SRCREV_appengine="5d1c1d03f8703c2e81478d9a30e9afa2d3e4bd8a"
SRC_URI += "git://github.com/golang/appengine;name=appengine;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/appengine"

# google.golang.org/genproto v0.0.0-20200224152610-e50cd9704f63
# [1] git ls-remote https://github.com/googleapis/go-genproto e50cd9704f63023d62cd06a1994b98227fc4d21a 
SRCREV_genproto="e50cd9704f63023d62cd06a1994b98227fc4d21a"
SRC_URI += "git://github.com/googleapis/go-genproto;name=genproto;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/genproto"

# google.golang.org/grpc v1.38.0
# [1] git ls-remote https://github.com/grpc/grpc-go 0257c8657362b76f24e7a8cfb61df48d4cb735d3 
SRCREV_grpc="0257c8657362b76f24e7a8cfb61df48d4cb735d3"
SRC_URI += "git://github.com/grpc/grpc-go;name=grpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/grpc"

# google.golang.org/grpc/cmd/protoc-gen-go-grpc v1.1.0
# [1] git ls-remote https://github.com/grpc/grpc-go c0198a9ce33b0755079e4cdae7f2315af2ebe993 
SRCREV_protoc-gen-go-grpc="c0198a9ce33b0755079e4cdae7f2315af2ebe993"
SRC_URI += "git://github.com/grpc/grpc-go;name=protoc-gen-go-grpc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/grpc/cmd/protoc-gen-go-grpc"

# google.golang.org/protobuf v1.27.1
# [1] git ls-remote https://github.com/protocolbuffers/protobuf-go b92717ecb630d4a4824b372bf98c729d87311a4d 
SRCREV_protobuf12="b92717ecb630d4a4824b372bf98c729d87311a4d"
SRC_URI += "git://github.com/protocolbuffers/protobuf-go;name=protobuf12;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/google.golang.org/protobuf"

# gopkg.in/airbrake/gobrake.v2 v2.0.9
# [1] git ls-remote https://gopkg.in/airbrake/gobrake.v2 668876711219e8b0206e2994bf0a59d889c775aa 
SRCREV_gobrake.v2="668876711219e8b0206e2994bf0a59d889c775aa"
SRC_URI += "git://gopkg.in/airbrake/gobrake.v2;name=gobrake.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/airbrake/gobrake.v2"

# gopkg.in/alecthomas/kingpin.v2 v2.2.6
# [1] git ls-remote https://gopkg.in/alecthomas/kingpin.v2 947dcec5ba9c011838740e680966fd7087a71d0d 
SRCREV_kingpin.v2="947dcec5ba9c011838740e680966fd7087a71d0d"
SRC_URI += "git://gopkg.in/alecthomas/kingpin.v2;name=kingpin.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/alecthomas/kingpin.v2"

# gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c
# [1] git ls-remote https://gopkg.in/check.v1 10cb98267c6cb43ea9cd6793f29ff4089c306974 
SRCREV_check.v1="10cb98267c6cb43ea9cd6793f29ff4089c306974"
SRC_URI += "git://gopkg.in/check.v1;name=check.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/check.v1"

# gopkg.in/cheggaaa/pb.v1 v1.0.25
# [1] git ls-remote https://gopkg.in/cheggaaa/pb.v1 8329f1a930db7e578b2c5aefb87b82c7c49016e1 
SRCREV_pb.v1="8329f1a930db7e578b2c5aefb87b82c7c49016e1"
SRC_URI += "git://gopkg.in/cheggaaa/pb.v1;name=pb.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/cheggaaa/pb.v1"

# gopkg.in/errgo.v2 v2.1.0
# [1] git ls-remote https://gopkg.in/errgo.v2 635edbc13741bd819966931e8b599c690b4f074d 
SRCREV_errgo.v2="635edbc13741bd819966931e8b599c690b4f074d"
SRC_URI += "git://gopkg.in/errgo.v2;name=errgo.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/errgo.v2"

# gopkg.in/fsnotify.v1 v1.4.7
# [1] git ls-remote https://gopkg.in/fsnotify.v1 c2828203cd70a50dcccfb2761f8b1f8ceef9a8e9 
SRCREV_fsnotify.v1="c2828203cd70a50dcccfb2761f8b1f8ceef9a8e9"
SRC_URI += "git://gopkg.in/fsnotify.v1;name=fsnotify.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/fsnotify.v1"

# gopkg.in/gcfg.v1 v1.2.0
# [1] git ls-remote https://gopkg.in/gcfg.v1 27e4946190b4a327b539185f2b5b1f7c84730728 
SRCREV_gcfg.v1="27e4946190b4a327b539185f2b5b1f7c84730728"
SRC_URI += "git://gopkg.in/gcfg.v1;name=gcfg.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/gcfg.v1"

# gopkg.in/gemnasium/logrus-airbrake-hook.v2 v2.1.2
# [1] git ls-remote https://gopkg.in/gemnasium/logrus-airbrake-hook.v2 bbcc56fcf0ca142c5f8e396cca816fb034967332 
SRCREV_logrus-airbrake-hook.v2="bbcc56fcf0ca142c5f8e396cca816fb034967332"
SRC_URI += "git://gopkg.in/gemnasium/logrus-airbrake-hook.v2;name=logrus-airbrake-hook.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/gemnasium/logrus-airbrake-hook.v2"

# gopkg.in/inf.v0 v0.9.1
# [1] git ls-remote https://gopkg.in/inf.v0 d2d2541c53f18d2a059457998ce2876cc8e67cbf 
SRCREV_inf.v0="d2d2541c53f18d2a059457998ce2876cc8e67cbf"
SRC_URI += "git://gopkg.in/inf.v0;name=inf.v0;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/inf.v0"

# gopkg.in/ini.v1 v1.62.0
# [1] git ls-remote https://gopkg.in/ini.v1 5e97220809ffaa826f787728501264e9114cb834 
SRCREV_ini.v1="5e97220809ffaa826f787728501264e9114cb834"
SRC_URI += "git://gopkg.in/ini.v1;name=ini.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/ini.v1"

# gopkg.in/natefinch/lumberjack.v2 v2.0.0
# [1] git ls-remote https://gopkg.in/natefinch/lumberjack.v2 2a59cad198e07a0ea1fad0b3d6733626861b5c65 
SRCREV_lumberjack.v2="2a59cad198e07a0ea1fad0b3d6733626861b5c65"
SRC_URI += "git://gopkg.in/natefinch/lumberjack.v2;name=lumberjack.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/natefinch/lumberjack.v2"

# gopkg.in/resty.v1 v1.12.0
# [1] git ls-remote https://gopkg.in/resty.v1 fa5875c0caa5c260ab78acec5a244215a730247f 
SRCREV_resty.v1="fa5875c0caa5c260ab78acec5a244215a730247f"
SRC_URI += "git://gopkg.in/resty.v1;name=resty.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/resty.v1"

# gopkg.in/square/go-jose.v2 v2.2.2
# [1] git ls-remote https://gopkg.in/square/go-jose.v2 215b07193e1c654935b8d2a1c4e5d6f7992ce617 
SRCREV_go-jose.v2="215b07193e1c654935b8d2a1c4e5d6f7992ce617"
SRC_URI += "git://gopkg.in/square/go-jose.v2;name=go-jose.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/square/go-jose.v2"

# gopkg.in/tomb.v1 v1.0.0-20141024135613-dd632973f1e7
# [1] git ls-remote https://gopkg.in/tomb.v1 dd632973f1e7218eb1089048e0798ec9ae7dceb8 
SRCREV_tomb.v1="dd632973f1e7218eb1089048e0798ec9ae7dceb8"
SRC_URI += "git://gopkg.in/tomb.v1;name=tomb.v1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/tomb.v1"

# gopkg.in/warnings.v0 v0.1.1
# [1] git ls-remote https://gopkg.in/warnings.v0 8a331561fe74dadba6edfc59f3be66c22c3b065d 
SRCREV_warnings.v0="8a331561fe74dadba6edfc59f3be66c22c3b065d"
SRC_URI += "git://gopkg.in/warnings.v0;name=warnings.v0;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/warnings.v0"

# gopkg.in/yaml.v2 v2.4.0
# [1] git ls-remote https://gopkg.in/yaml.v2 7649d4548cb53a614db133b2a8ac1f31859dda8c 
SRCREV_yaml.v2="7649d4548cb53a614db133b2a8ac1f31859dda8c"
SRC_URI += "git://gopkg.in/yaml.v2;name=yaml.v2;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/yaml.v2"

# gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b
# [1] git ls-remote https://gopkg.in/yaml.v3 496545a6307b2a7d7a710fd516e5e16e8ab62dbc 
SRCREV_yaml.v3="496545a6307b2a7d7a710fd516e5e16e8ab62dbc"
SRC_URI += "git://gopkg.in/yaml.v3;name=yaml.v3;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/gopkg.in/yaml.v3"

# gotest.tools v2.2.0+incompatible
# [1] git ls-remote https://github.com/gotestyourself/gotest.tools 7c797b5133e5460410dbb22ba779bf35e6975dea 
SRCREV_gotest.tools="7c797b5133e5460410dbb22ba779bf35e6975dea"
SRC_URI += "git://github.com/gotestyourself/gotest.tools;name=gotest.tools;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gotestyourself/gotest.tools"

# gotest.tools/v3 v3.0.3
# [1] git ls-remote https://github.com/gotestyourself/gotest.tools 568bc57cc5c19a2ef85e5749870b49a4cc2ab54d 
SRCREV_v3123456789="568bc57cc5c19a2ef85e5749870b49a4cc2ab54d"
SRC_URI += "git://github.com/gotestyourself/gotest.tools;name=v3123456789;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/gotestyourself/gotest.tools568bc57cc5c19a2ef85e5749870b49a4cc2ab54d"

# honnef.co/go/tools v0.2.2
# [1] git ls-remote https://github.com/dominikh/go-tools e45d48d0ce974563d846121b451f55c20acfc9cd 
SRCREV_tools1="e45d48d0ce974563d846121b451f55c20acfc9cd"
SRC_URI += "git://github.com/dominikh/go-tools;name=tools1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/honnef.co/go/tools"

# inet.af/tcpproxy v0.0.0-20200125044825-b6bb9b5b8252
# [1] git ls-remote https://github.com/inetaf/tcpproxy b6bb9b5b82524122bcf27291ede32d1517a14ab8 
SRCREV_tcpproxy="b6bb9b5b82524122bcf27291ede32d1517a14ab8"
SRC_URI += "git://github.com/inetaf/tcpproxy;name=tcpproxy;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/inet.af/tcpproxy"

# github.com/k3s-io/kubernetes/staging/src/k8s.io/api v1.22.6-k3s1
# [1] git ls-remote https://github.com/k3s-io/kubernetes 4ffc33b0cfb40b12ee1c687503491d9e17009928 
SRCREV_api123="4ffc33b0cfb40b12ee1c687503491d9e17009928"
SRC_URI += "git://github.com/k3s-io/kubernetes;name=api123;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/kubernetes/staging/src/k8s.io/api"

# github.com/kubernetes/gengo v0.0.0-20201214224949-b6c5ce23f027
# [1] git ls-remote https://github.com/kubernetes/gengo b6c5ce23f0274839a68889e60dfea0ba05302109 
SRCREV_gengo="b6c5ce23f0274839a68889e60dfea0ba05302109"
SRC_URI += "git://github.com/kubernetes/gengo;name=gengo;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/gengo"

# github.com/k3s-io/klog v1.0.0-k3s2
# [1] git ls-remote https://github.com/k3s-io/klog e94f416e9301d90f5c8d6043c999ea179bd9b455 
SRCREV_klog="e94f416e9301d90f5c8d6043c999ea179bd9b455"
SRC_URI += "git://github.com/k3s-io/klog;name=klog;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/klog"

# github.com/k3s-io/klog/v2 v2.9.0-k3s2
# [1] git ls-remote https://github.com/k3s-io/klog 92394dadeec2079ad3102572fc8abf0a885cdae6 
SRCREV_v21234567="92394dadeec2079ad3102572fc8abf0a885cdae6"
SRC_URI += "git://github.com/k3s-io/klog;name=v21234567;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/k3s-io/klog/v2"

# github.com/kubernetes/kube-openapi v0.0.0-20211109043538-20434351676c
# [1] git ls-remote https://github.com/kubernetes/kube-openapi 20434351676c2bbd010b1f864dac03c799858023 
SRCREV_kube-openapi="20434351676c2bbd010b1f864dac03c799858023"
SRC_URI += "git://github.com/kubernetes/kube-openapi;name=kube-openapi;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/kube-openapi"

# github.com/kubernetes/system-validators v1.5.0
# [1] git ls-remote https://github.com/kubernetes/system-validators 82ab84f11f7ae7b531b90f6a9aec18202fccc11f 
SRCREV_system-validators="82ab84f11f7ae7b531b90f6a9aec18202fccc11f"
SRC_URI += "git://github.com/kubernetes/system-validators;name=system-validators;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/system-validators"

# github.com/kubernetes/utils v0.0.0-20210819203725-bdf08cb9a70a
# [1] git ls-remote https://github.com/kubernetes/utils bdf08cb9a70a05bd10b6fe605643a9cbab6effd5 
SRCREV_utils="bdf08cb9a70a05bd10b6fe605643a9cbab6effd5"
SRC_URI += "git://github.com/kubernetes/utils;name=utils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/k8s.io/utils"

# modernc.org/cc v1.0.0
# [1] git ls-remote https://gitlab.com/cznic/cc 38a4d54db3b80250bc24d7dd0ac540be62efdcda 
SRCREV_cc="38a4d54db3b80250bc24d7dd0ac540be62efdcda"
SRC_URI += "git://gitlab.com/cznic/cc;name=cc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/modernc.org/cc"

# modernc.org/golex v1.0.0
# [1] git ls-remote https://gitlab.com/cznic/golex d746c229646901b48840606ac77fa7878d9818ba 
SRCREV_golex="d746c229646901b48840606ac77fa7878d9818ba"
SRC_URI += "git://gitlab.com/cznic/golex;name=golex;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/modernc.org/golex"

# modernc.org/mathutil v1.0.0
# [1] git ls-remote https://gitlab.com/cznic/mathutil 44d67c390eec11366b364548f77bf1c04462658c 
SRCREV_mathutil="44d67c390eec11366b364548f77bf1c04462658c"
SRC_URI += "git://gitlab.com/cznic/mathutil;name=mathutil;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/modernc.org/mathutil"

# modernc.org/strutil v1.0.0
# [1] git ls-remote https://gitlab.com/cznic/strutil 0d0c5de42e2b9c28090f8d87a145d83aa9bfd651 
SRCREV_strutil="0d0c5de42e2b9c28090f8d87a145d83aa9bfd651"
SRC_URI += "git://gitlab.com/cznic/strutil;name=strutil;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/modernc.org/strutil"

# modernc.org/xc v1.0.0
# [1] git ls-remote https://gitlab.com/cznic/xc ee024816a7d98ca3a45f6f8a5f40fbdcb23e1318 
SRCREV_xc="ee024816a7d98ca3a45f6f8a5f40fbdcb23e1318"
SRC_URI += "git://gitlab.com/cznic/xc;name=xc;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/modernc.org/xc"

# rsc.io/binaryregexp v0.2.0
# [1] git ls-remote https://github.com/rsc/binaryregexp 857b9542aaa89cfa42a1477b43fa1f24192fe921 
SRCREV_binaryregexp="857b9542aaa89cfa42a1477b43fa1f24192fe921"
SRC_URI += "git://github.com/rsc/binaryregexp;name=binaryregexp;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/rsc.io/binaryregexp"

# rsc.io/pdf v0.1.1
# [1] git ls-remote https://github.com/rsc/pdf 48d040297cebccc9e8dc43927e1b8036ecd33bfe 
SRCREV_pdf="48d040297cebccc9e8dc43927e1b8036ecd33bfe"
SRC_URI += "git://github.com/rsc/pdf;name=pdf;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/rsc.io/pdf"

# rsc.io/quote/v3 v3.1.0
# [1] git ls-remote https://github.com/rsc/quote 0406d7298882187f4c75f75fa85cc808a64bcef1 
SRCREV_v312345678910="0406d7298882187f4c75f75fa85cc808a64bcef1"
SRC_URI += "git://github.com/rsc/quote;name=v312345678910;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/rsc/quote/v3"

# rsc.io/sampler v1.3.0
# [1] git ls-remote https://github.com/rsc/sampler 0cc034b51e57ed7832d4c67d526f75a900996e5c 
SRCREV_sampler="0cc034b51e57ed7832d4c67d526f75a900996e5c"
SRC_URI += "git://github.com/rsc/sampler;name=sampler;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/rsc.io/sampler"

# github.com/kubernetes-sigs/apiserver-network-proxy/konnectivity-client v0.0.27
# [1] git ls-remote https://github.com/kubernetes-sigs/apiserver-network-proxy 21b41da407fde6d64ff30066702d03653393e8e2 
SRCREV_konnectivity-client="21b41da407fde6d64ff30066702d03653393e8e2"
SRC_URI += "git://github.com/kubernetes-sigs/apiserver-network-proxy;name=konnectivity-client;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kubernetes-sigs/apiserver-network-proxy/konnectivity-client"

# github.com/kubernetes-sigs/cli-utils v0.16.0
# [1] git ls-remote https://github.com/kubernetes-sigs/cli-utils 07e70706507fffdaba787571d3000fdd58ebab3d 
SRCREV_cli-utils="07e70706507fffdaba787571d3000fdd58ebab3d"
SRC_URI += "git://github.com/kubernetes-sigs/cli-utils;name=cli-utils;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/cli-utils"

# github.com/kubernetes-sigs/controller-runtime v0.4.0
# [1] git ls-remote https://github.com/kubernetes-sigs/controller-runtime 198197fe0fd7553cadd8afcd3338f8ee4b8a7e3f 
SRCREV_controller-runtime="198197fe0fd7553cadd8afcd3338f8ee4b8a7e3f"
SRC_URI += "git://github.com/kubernetes-sigs/controller-runtime;name=controller-runtime;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/controller-runtime"

# github.com/kubernetes-sigs/kustomize/api v0.8.11
# [1] git ls-remote https://github.com/kubernetes-sigs/kustomize 7e0fd02783ba65319b94076efb6b2414923feb86 
#SRCREV_api1234="70ce89d9935877822f2f84fc1678be3d1645a733"
SRCREV_api1234="c819d69ae4982d58df467d28b264560c8810a39d"
SRC_URI += "git://github.com/kubernetes-sigs/kustomize;name=api1234;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kubernetes-sigs/kustomize/api"

# github.com/kubernetes-sigs/structured-merge-diff/v4 v4.2.1
# [1] git ls-remote https://github.com/kubernetes-sigs/structured-merge-diff 65611e5f7fc60e909529889c29faa9cac17cb485 
SRCREV_v41="65611e5f7fc60e909529889c29faa9cac17cb485"
SRC_URI += "git://github.com/kubernetes-sigs/structured-merge-diff;name=v41;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/github.com/kubernetes-sigs/structured-merge-diff/v4"

# github.com/kubernetes-sigs/testing_frameworks v0.1.2
# [1] git ls-remote https://github.com/kubernetes-sigs/testing_frameworks c7087048c932a346b910a2240f3a053e544eb352 
SRCREV_testing_frameworks="c7087048c932a346b910a2240f3a053e544eb352"
SRC_URI += "git://github.com/kubernetes-sigs/testing_frameworks;name=testing_frameworks;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/testing_frameworks"

# github.com/kubernetes-sigs/yaml v1.2.0
# [1] git ls-remote https://github.com/kubernetes-sigs/yaml 9fc95527decd95bb9d28cc2eab08179b2d0f6971 
SRCREV_yaml1="9fc95527decd95bb9d28cc2eab08179b2d0f6971"
SRC_URI += "git://github.com/kubernetes-sigs/yaml;name=yaml1;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/yaml"

# github.com/kubernetes-sigs/json v0.0.0-20210819203725-bdf08cb9a70a
# [1] git ls-remote https://github.com/kubernetes-sigs/json 227cbc7cc124bd5ca34310d537f3662d6cf28153 
SRCREV_json="227cbc7cc124bd5ca34310d537f3662d6cf28153"
SRC_URI += "git://github.com/kubernetes-sigs/json;name=json;protocol=https;nobranch=1;destsuffix=${WORKDIR}/${BP}/src/import/vendor.fetch/sigs.k8s.io/json"

