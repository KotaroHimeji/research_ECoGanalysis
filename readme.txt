■手順
1.  https://bicr.atr.jp//cbi/sparse_estimation/sato/VBSR.html
    にアクセス後、Latest versionをダウンロードして、パスを通しておく

2.  サルの生データは、ECoG_EMG_Analysis/[saru]/ShairdData に入れる


3.  解析手順としては、FullPreFilt.m → AnalysisVBSR.m
    の順で使用する


■ディレクトリ構造


ECoG_EMG_Analysis
    +function
    |   +bilt_in
    |   +CC
    |   +fig
    |   +Filter
    |   +forTestset
    |   +AnalysisVBSR.m
    |   +FullPreFilt.m
    |   +checkTimingGap_reconstruction.m
    +Ni
    |   +Figure
    |   +FiltData
    |   +ShairdData
    |   +VBSR_result
    +Wa
    |   +Figure
    |   +FiltData
    |   +ShairdData
    |   +VBSR_result
    +testset
    |   +Figure
    |   +FiltData
    |   +ShairdData
    |   +VBSR_result






