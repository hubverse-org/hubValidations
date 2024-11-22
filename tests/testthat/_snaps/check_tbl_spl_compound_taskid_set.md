# check_tbl_spl_compound_taskid_set works

    Code
      check_tbl_spl_compound_taskid_set(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      All samples in a model task conform to single, unique compound task ID set that matches or is coarser than the configured `compound_taksid_set`.

---

    Code
      check_tbl_spl_compound_taskid_set(tbl_subset, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      All samples in a model task conform to single, unique compound task ID set that matches or is coarser than the configured `compound_taksid_set`.

---

    Code
      check_tbl_spl_compound_taskid_set(tbl_error, round_id, file_path, hub_path)
    Output
      <error/check_error>
      Error:
      ! All samples in a model task do not conform to single, unique compound task ID set that matches or is coarser than the configured `compound_taksid_set`.  mt 2: Finer `compound_taskid_set` than allowed detected. "horizon" identified as compound task ID in file but not allowed in config. Compound task IDs should be one of "reference_date" and "location".

---

    Code
      error_check$errors
    Output
      $`2`
      $`2`[[1]]
      $`2`[[1]]$config_comp_tids
      [1] "reference_date" "location"      
      
      $`2`[[1]]$invalid_tbl_comp_tids
      [1] "horizon"
      
      $`2`[[1]]$tbl_comp_tids
      [1] "reference_date" "horizon"        "location"      
      
      $`2`[[1]]$output_type_ids
        [1] "1"    "10"   "100"  "101"  "102"  "103"  "104"  "105"  "106"  "107" 
       [11] "108"  "109"  "11"   "110"  "111"  "112"  "113"  "114"  "115"  "116" 
       [21] "117"  "118"  "119"  "12"   "120"  "121"  "122"  "123"  "124"  "125" 
       [31] "126"  "127"  "128"  "129"  "13"   "130"  "131"  "132"  "133"  "134" 
       [41] "135"  "136"  "137"  "138"  "139"  "14"   "140"  "141"  "142"  "143" 
       [51] "144"  "145"  "146"  "147"  "148"  "149"  "15"   "150"  "151"  "152" 
       [61] "153"  "154"  "155"  "156"  "157"  "158"  "159"  "16"   "160"  "161" 
       [71] "162"  "163"  "164"  "165"  "166"  "167"  "168"  "169"  "17"   "170" 
       [81] "171"  "172"  "173"  "174"  "175"  "176"  "177"  "178"  "179"  "18"  
       [91] "180"  "181"  "182"  "183"  "184"  "185"  "186"  "187"  "188"  "189" 
      [101] "19"   "190"  "191"  "192"  "193"  "194"  "195"  "196"  "197"  "198" 
      [111] "199"  "2"    "20"   "200"  "201"  "202"  "203"  "204"  "205"  "206" 
      [121] "207"  "208"  "209"  "21"   "210"  "211"  "212"  "213"  "214"  "215" 
      [131] "216"  "217"  "218"  "219"  "22"   "220"  "221"  "222"  "223"  "224" 
      [141] "225"  "226"  "227"  "228"  "229"  "23"   "230"  "231"  "232"  "233" 
      [151] "234"  "235"  "236"  "237"  "238"  "239"  "24"   "240"  "241"  "242" 
      [161] "243"  "244"  "245"  "246"  "247"  "248"  "249"  "25"   "250"  "251" 
      [171] "252"  "253"  "254"  "255"  "256"  "257"  "258"  "259"  "26"   "260" 
      [181] "261"  "262"  "263"  "264"  "265"  "266"  "267"  "268"  "269"  "27"  
      [191] "270"  "271"  "272"  "273"  "274"  "275"  "276"  "277"  "278"  "279" 
      [201] "28"   "280"  "281"  "282"  "283"  "284"  "285"  "286"  "287"  "288" 
      [211] "289"  "29"   "290"  "291"  "292"  "293"  "294"  "295"  "296"  "297" 
      [221] "298"  "299"  "3"    "30"   "300"  "301"  "302"  "303"  "304"  "305" 
      [231] "306"  "307"  "308"  "309"  "31"   "310"  "311"  "312"  "313"  "314" 
      [241] "315"  "316"  "317"  "318"  "319"  "32"   "320"  "321"  "322"  "323" 
      [251] "324"  "325"  "326"  "327"  "328"  "329"  "33"   "330"  "331"  "332" 
      [261] "333"  "334"  "335"  "336"  "337"  "338"  "339"  "34"   "340"  "341" 
      [271] "342"  "343"  "344"  "345"  "346"  "347"  "348"  "349"  "35"   "350" 
      [281] "351"  "352"  "353"  "354"  "355"  "356"  "357"  "358"  "359"  "36"  
      [291] "360"  "361"  "362"  "363"  "364"  "365"  "366"  "367"  "368"  "369" 
      [301] "37"   "370"  "371"  "372"  "373"  "374"  "375"  "376"  "377"  "378" 
      [311] "379"  "38"   "380"  "381"  "382"  "383"  "384"  "385"  "386"  "387" 
      [321] "388"  "389"  "39"   "390"  "391"  "392"  "393"  "394"  "395"  "396" 
      [331] "397"  "398"  "399"  "4"    "40"   "400"  "41"   "42"   "43"   "44"  
      [341] "45"   "46"   "47"   "48"   "49"   "5"    "50"   "51"   "52"   "5201"
      [351] "5202" "5203" "5204" "5205" "5206" "5207" "5208" "5209" "5210" "5211"
      [361] "5212" "5213" "5214" "5215" "5216" "5217" "5218" "5219" "5220" "5221"
      [371] "5222" "5223" "5224" "5225" "5226" "5227" "5228" "5229" "5230" "5231"
      [381] "5232" "5233" "5234" "5235" "5236" "5237" "5238" "5239" "5240" "5241"
      [391] "5242" "5243" "5244" "5245" "5246" "5247" "5248" "5249" "5250" "5251"
      [401] "5252" "5253" "5254" "5255" "5256" "5257" "5258" "5259" "5260" "5261"
      [411] "5262" "5263" "5264" "5265" "5266" "5267" "5268" "5269" "5270" "5271"
      [421] "5272" "5273" "5274" "5275" "5276" "5277" "5278" "5279" "5280" "5281"
      [431] "5282" "5283" "5284" "5285" "5286" "5287" "5288" "5289" "5290" "5291"
      [441] "5292" "5293" "5294" "5295" "5296" "5297" "5298" "5299" "53"   "5300"
      [451] "54"   "55"   "56"   "57"   "58"   "59"   "6"    "60"   "61"   "62"  
      [461] "63"   "64"   "65"   "66"   "67"   "68"   "69"   "7"    "70"   "71"  
      [471] "72"   "73"   "74"   "75"   "76"   "77"   "78"   "79"   "8"    "80"  
      [481] "81"   "82"   "83"   "84"   "85"   "86"   "87"   "88"   "89"   "9"   
      [491] "90"   "91"   "92"   "93"   "94"   "95"   "96"   "97"   "98"   "99"  
      
      
      

---

    Code
      check_tbl_spl_compound_taskid_set(tbl_error_dups, round_id, file_path, hub_path)
    Output
      <error/check_error>
      Error:
      ! All samples in a model task do not conform to single, unique compound task ID set that matches or is coarser than the configured `compound_taksid_set`.  mt 2: More than 1 unique `compound_taskid_set` detected. See `errors` attribute for details.

---

    Code
      error_dup_check$errors
    Output
      $`2`
      $`2`[[1]]
      $`2`[[1]]$tbl_comp_tids
      [1] "reference_date" "location"      
      
      $`2`[[1]]$output_type_ids
        [1] "1"    "10"   "100"  "101"  "102"  "103"  "104"  "105"  "106"  "107" 
       [11] "108"  "109"  "11"   "110"  "111"  "112"  "113"  "114"  "115"  "116" 
       [21] "117"  "118"  "119"  "12"   "120"  "121"  "122"  "123"  "124"  "125" 
       [31] "126"  "127"  "128"  "129"  "13"   "130"  "131"  "132"  "133"  "134" 
       [41] "135"  "136"  "137"  "138"  "139"  "14"   "140"  "141"  "142"  "143" 
       [51] "144"  "145"  "146"  "147"  "148"  "149"  "15"   "150"  "151"  "152" 
       [61] "153"  "154"  "155"  "156"  "157"  "158"  "159"  "16"   "160"  "161" 
       [71] "162"  "163"  "164"  "165"  "166"  "167"  "168"  "169"  "17"   "170" 
       [81] "171"  "172"  "173"  "174"  "175"  "176"  "177"  "178"  "179"  "18"  
       [91] "180"  "181"  "182"  "183"  "184"  "185"  "186"  "187"  "188"  "189" 
      [101] "19"   "190"  "191"  "192"  "193"  "194"  "195"  "196"  "197"  "198" 
      [111] "199"  "2"    "20"   "200"  "201"  "202"  "203"  "204"  "205"  "206" 
      [121] "207"  "208"  "209"  "21"   "210"  "211"  "212"  "213"  "214"  "215" 
      [131] "216"  "217"  "218"  "219"  "22"   "220"  "221"  "222"  "223"  "224" 
      [141] "225"  "226"  "227"  "228"  "229"  "23"   "230"  "231"  "232"  "233" 
      [151] "234"  "235"  "236"  "237"  "238"  "239"  "24"   "240"  "241"  "242" 
      [161] "243"  "244"  "245"  "246"  "247"  "248"  "249"  "25"   "250"  "251" 
      [171] "252"  "253"  "254"  "255"  "256"  "257"  "258"  "259"  "26"   "260" 
      [181] "261"  "262"  "263"  "264"  "265"  "266"  "267"  "268"  "269"  "27"  
      [191] "270"  "271"  "272"  "273"  "274"  "275"  "276"  "277"  "278"  "279" 
      [201] "28"   "280"  "281"  "282"  "283"  "284"  "285"  "286"  "287"  "288" 
      [211] "289"  "29"   "290"  "291"  "292"  "293"  "294"  "295"  "296"  "297" 
      [221] "298"  "299"  "3"    "30"   "300"  "301"  "302"  "303"  "304"  "305" 
      [231] "306"  "307"  "308"  "309"  "31"   "310"  "311"  "312"  "313"  "314" 
      [241] "315"  "316"  "317"  "318"  "319"  "32"   "320"  "321"  "322"  "323" 
      [251] "324"  "325"  "326"  "327"  "328"  "329"  "33"   "330"  "331"  "332" 
      [261] "333"  "334"  "335"  "336"  "337"  "338"  "339"  "34"   "340"  "341" 
      [271] "342"  "343"  "344"  "345"  "346"  "347"  "348"  "349"  "35"   "350" 
      [281] "351"  "352"  "353"  "354"  "355"  "356"  "357"  "358"  "359"  "36"  
      [291] "360"  "361"  "362"  "363"  "364"  "365"  "366"  "367"  "368"  "369" 
      [301] "37"   "370"  "371"  "372"  "373"  "374"  "375"  "376"  "377"  "378" 
      [311] "379"  "38"   "380"  "381"  "382"  "383"  "384"  "385"  "386"  "387" 
      [321] "388"  "389"  "39"   "390"  "391"  "392"  "393"  "394"  "395"  "396" 
      [331] "397"  "398"  "399"  "4"    "40"   "400"  "41"   "42"   "43"   "44"  
      [341] "45"   "46"   "47"   "48"   "49"   "5"    "50"   "51"   "52"   "5201"
      [351] "5202" "5203" "5204" "5205" "5206" "5207" "5208" "5209" "5210" "5211"
      [361] "5212" "5213" "5214" "5215" "5216" "5217" "5218" "5219" "5220" "5221"
      [371] "5222" "5223" "5224" "5225" "5226" "5227" "5228" "5229" "5230" "5231"
      [381] "5232" "5233" "5234" "5235" "5236" "5237" "5238" "5239" "5240" "5241"
      [391] "5242" "5243" "5244" "5245" "5246" "5247" "5248" "5249" "5250" "5251"
      [401] "5252" "5253" "5254" "5255" "5256" "5257" "5258" "5259" "5260" "5261"
      [411] "5262" "5263" "5264" "5265" "5266" "5267" "5268" "5269" "5270" "5271"
      [421] "5272" "5273" "5274" "5275" "5276" "5277" "5278" "5279" "5280" "5281"
      [431] "5282" "5283" "5284" "5285" "5286" "5287" "5288" "5289" "5290" "5291"
      [441] "5292" "5293" "5294" "5295" "5296" "5297" "5298" "5299" "53"   "5300"
      [451] "54"   "55"   "56"   "57"   "58"   "59"   "6"    "60"   "61"   "62"  
      [461] "63"   "64"   "65"   "66"   "67"   "68"   "69"   "7"    "70"   "71"  
      [471] "72"   "73"   "74"   "75"   "76"   "77"   "78"   "79"   "8"    "80"  
      [481] "81"   "82"   "83"   "84"   "85"   "86"   "87"   "88"   "89"   "9"   
      [491] "90"   "91"   "92"   "93"   "94"   "95"   "96"   "97"   "98"  
      
      
      $`2`[[2]]
      $`2`[[2]]$tbl_comp_tids
      [1] "reference_date" "horizon"        "location"      
      
      $`2`[[2]]$output_type_ids
      [1] "1"
      
      
      

# Different compound_taskid_sets work

    Code
      str(check_tbl_spl_compound_taskid_set(tbl_coarse_location, "2022-10-29",
        create_file_path("2022-10-29"), hub_path))
    Output
      List of 6
       $ message            : chr "All samples in a model task conform to single, unique compound task ID set that matches or is\n    coarser than"| __truncated__
       $ where              : 'fs_path' chr "flu-base/2022-10-29-flu-base.parquet"
       $ errors             : NULL
       $ compound_taskid_set:List of 2
        ..$ 1: NULL
        ..$ 2: chr [1:2] "reference_date" "location"
       $ call               : chr "check_tbl_spl_compound_taskid_set"
       $ use_cli_format     : logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

---

    Code
      str(check_tbl_spl_compound_taskid_set(tbl_coarse_horizon, "2022-11-05",
        create_file_path("2022-11-05"), hub_path))
    Output
      List of 6
       $ message            : chr "All samples in a model task conform to single, unique compound task ID set that matches or is\n    coarser than"| __truncated__
       $ where              : 'fs_path' chr "flu-base/2022-11-05-flu-base.parquet"
       $ errors             : NULL
       $ compound_taskid_set:List of 2
        ..$ 1: NULL
        ..$ 2: chr [1:3] "reference_date" "horizon" "target_end_date"
       $ call               : chr "check_tbl_spl_compound_taskid_set"
       $ use_cli_format     : logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

---

    Code
      str(check_tbl_spl_compound_taskid_set(tbl_coarse_horizon, "2022-11-05",
        create_file_path("2022-11-05"), hub_path))
    Output
      List of 8
       $ message            : chr "All samples in a model task do not conform to single, unique compound task ID set that matches or is\n    coars"| __truncated__
       $ trace              : NULL
       $ parent             : NULL
       $ where              : 'fs_path' chr "flu-base/2022-11-05-flu-base.parquet"
       $ errors             :List of 1
        ..$ 2:List of 1
        .. ..$ :List of 4
        .. .. ..$ config_comp_tids     : chr [1:4] "reference_date" "horizon" "location" "variant"
        .. .. ..$ invalid_tbl_comp_tids: chr "target_end_date"
        .. .. ..$ tbl_comp_tids        : chr [1:3] "reference_date" "horizon" "target_end_date"
        .. .. ..$ output_type_ids      : chr [1:40] "1" "10" "11" "12" ...
       $ compound_taskid_set: logi NA
       $ call               : chr "check_tbl_spl_compound_taskid_set"
       $ use_cli_format     : logi TRUE
       - attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      str(check_tbl_spl_compound_taskid_set(tbl_coarse_horizon, "2022-11-05",
        create_file_path("2022-11-05"), hub_path, derived_task_ids = "target_end_date"))
    Output
      List of 6
       $ message            : chr "All samples in a model task conform to single, unique compound task ID set that matches or is\n    coarser than"| __truncated__
       $ where              : 'fs_path' chr "flu-base/2022-11-05-flu-base.parquet"
       $ errors             : NULL
       $ compound_taskid_set:List of 2
        ..$ 1: NULL
        ..$ 2: chr [1:2] "reference_date" "horizon"
       $ call               : chr "check_tbl_spl_compound_taskid_set"
       $ use_cli_format     : logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

# Finer compound_taskid_sets work

    Code
      check_tbl_spl_compound_taskid_set(tbl_fine, "2022-10-22", create_file_path(
        "2022-10-22"), test_path("testdata/hub-spl"))
    Output
      <error/check_error>
      Error:
      ! All samples in a model task do not conform to single, unique compound task ID set that matches or is coarser than the configured `compound_taksid_set`.  mt 2: Finer `compound_taskid_set` than allowed detected. "variant" identified as compound task ID in file but not allowed in config. Compound task IDs should be one of "reference_date", "horizon", "location", and "target_end_date".

---

    Code
      str(check_tbl_spl_compound_taskid_set(tbl_fine, "2022-10-22", create_file_path(
        "2022-10-22"), test_path("testdata/hub-spl")))
    Output
      List of 8
       $ message            : chr "All samples in a model task do not conform to single, unique compound task ID set that matches or is\n    coars"| __truncated__
       $ trace              : NULL
       $ parent             : NULL
       $ where              : 'fs_path' chr "flu-base/2022-10-22-flu-base.parquet"
       $ errors             :List of 1
        ..$ 2:List of 1
        .. ..$ :List of 4
        .. .. ..$ config_comp_tids     : chr [1:4] "reference_date" "horizon" "location" "target_end_date"
        .. .. ..$ invalid_tbl_comp_tids: chr "variant"
        .. .. ..$ tbl_comp_tids        : chr [1:5] "reference_date" "horizon" "location" "variant" ...
        .. .. ..$ output_type_ids      : chr [1:800] "1" "10" "100" "101" ...
       $ compound_taskid_set: logi NA
       $ call               : chr "check_tbl_spl_compound_taskid_set"
       $ use_cli_format     : logi TRUE
       - attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

# Ignoring derived_task_ids in check_tbl_spl_compound_taskid_set works

    Code
      check_tbl_spl_compound_taskid_set(tbl, round_id, file_path, hub_path,
        derived_task_ids = "target_end_date")
    Output
      <message/check_success>
      Message:
      All samples in a model task conform to single, unique compound task ID set that matches or is coarser than the configured `compound_taksid_set`.

