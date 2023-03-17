class Session {

    PaceTime mean {
        get {
            return meanCache.value;
        }
    };

    PaceTime median {
        get {
            return medianCache.value;
        }
    }

    PaceTime lastFinish{
        get {
            return lastFinishCache.value;
        }
    };

    PaceTime fastestFinish{
        get {
            return fastestFinishCache.value;
        }
    };

    PaceTime slowestFinish{
        get {
            return slowestFinishCache.value;
        }
    };

    int finishes {
        get {
            return finishesCache.value;
        }
    }

    int attempts {
        get {
            return attemptsCache.value;
        }
    }

    float finishPercent {
        get {
            return finishPercentCache.value;
        }
    }

    int IQR {
        get {
            return iqrCache.value;
        }
    }

    int range {
        get {
            return rangeCache.value;
        }
    }

    float StandardDeviation {
        get {
            return standardDeviationCache.value;
        }
    }

    float MAD {
        get {
            return madCache.value;
        }
    }

    int tab {
        get {
            return tabstate;
        }
    }

    RunManager@ rm;
    bool started = false;
    string mapName = "";
    string authorName = "";

    private bool attemptHandled = false;
    private bool finishHandled = false;
    private bool attemptEndedFlag = false;
    private bool finishFlag = false;
    private bool finishAdded = true;
    private bool running;
    private string mapId = "";
    private int tabstate = 0;

    // Cache
    private PaceCache@ meanCache;
    private PaceCache@ medianCache;
    private PaceCache@ lastFinishCache;
    private PaceCache@ fastestFinishCache;
    private PaceCache@ slowestFinishCache;
    private IntCache@  finishesCache;
    private IntCache@  attemptsCache;
    private IntCache@  iqrCache;
    private IntCache@  rangeCache;
    private FloatCache@ finishPercentCache;
    private FloatCache@ standardDeviationCache;
    private FloatCache@ madCache;

    Session() {}

    void start() {
        running = true;

        auto ps = PlayerState::GetRaceData();

        @rm = RunManager(this);
        @meanCache = MeanPaceCache(this);
        @medianCache = MedianCache(this);
        @lastFinishCache = LastFinishCache(this);
        @fastestFinishCache = FastestFinishCache(this);
        @slowestFinishCache = SlowestFinishCache(this);
        @finishesCache = FinishesCache(this);
        @attemptsCache = AttemptsCache(this);
        @iqrCache = IQRCache(this);
        @rangeCache = RangeCache(this);
        @finishPercentCache = FinishesPercentCache(this);
        @standardDeviationCache = StandardDeviationCache(this);
        @madCache = MADCache(this);
        
        mapId = ps.dMapInfo.EdChallengeId;
        mapName = ps.dMapInfo.MapName;
        authorName = ps.dMapInfo.AuthorNickName;

        if (isDataPersistent) readPersistentFile();

        started = true;
        startnew(CoroutineFunc(handler));
    }

    void updateTabState(int tab) {
        if (tabstate != tab) {
            tabstate = tab;
            invalidateCache();
        }
    }

    void invalidateCache() {
        rm.setSlice(tab);
        meanCache.invalidate();
        medianCache.invalidate();
        lastFinishCache.invalidate();
        fastestFinishCache.invalidate();
        slowestFinishCache.invalidate();
        finishesCache.invalidate();
        attemptsCache.invalidate();
        iqrCache.invalidate();
        rangeCache.invalidate();
        finishPercentCache.invalidate();
        standardDeviationCache.invalidate();
        madCache.invalidate();
    }

    void handler() {
        while(running) {
                if (!isOnTrack()) {
                    writeFile();
                    running = false;
                }

                auto app = cast<CTrackMania>(GetApp());
                auto ps = PlayerState::GetRaceData();
                auto playground = app.CurrentPlayground;
                if (playground !is null && playground.GameTerminals.Length > 0) {
                
                    auto terminal = playground.GameTerminals[0];
                    auto player = cast<CSmPlayer>(terminal.ControlledPlayer);
                    if (player !is null) {

                        auto post = (cast<CSmScriptPlayer>(player.ScriptAPI)).Post;
                        auto uiSequence = terminal.UISequence_Current;

                        if (!attemptHandled && post == CSmScriptPlayer::EPost::Char) {
                            attemptHandled = true;
                            attemptEndedFlag = true;
                        } 
                        if (attemptHandled && post != CSmScriptPlayer::EPost::Char) {
                            attemptHandled = false;
                        }

                        if (!finishHandled && uiSequence == CGamePlaygroundUIConfig::EUISequence::Finish) {
                            finishHandled = true;
                            finishFlag = true;
                        }

                        if (finishHandled && uiSequence != CGamePlaygroundUIConfig::EUISequence::Finish) {
                            finishHandled = false;
                        }

                        if (finishFlag && !finishAdded) {
                            rm.add(CompletedRun(PaceTime(this, ps.dMLData.PlayerLastCheckpointTime)));
                            invalidateCache();
                            finishAdded = true;
                        }

                        if (attemptEndedFlag) {
                            if (!finishAdded) rm.add(DnfRun());
                            invalidateCache();
                            attemptEndedFlag = false;
                            finishFlag = false;
                            finishAdded = false;
                        }
                    }
                }
                yield();
            }
    }

    Json::Value collectJsonContent() {
        auto content = Json::Object();

            auto jsonFinishTimes = Json::Array();

            for (int i = 0; i < rm.trackedRuns.Length; i++) {
                if (rm.trackedRuns[i].type() == RunType::completed) jsonFinishTimes.Add((cast<CompletedRun>(rm.trackedRuns[i])).time.finishTime);
                if (rm.trackedRuns[i].type() == RunType::dnf) jsonFinishTimes.Add("DNF");
            }

            content["FinishTimes"] = jsonFinishTimes;
            content["LastSavedAt"] = Text::Format("%0d", Time::get_Stamp());
            content["MapName"] = StripFormatCodes(mapName);
            content["Author"] = StripFormatCodes(authorName);
            content["MapId"] = mapId;

            content["StatmaniaJsonVersion"] = 1;

            return content;
    }

    void readPersistentFile() {
        string jsonFile = IO::FromStorageFolder(mapId + ".json");

        if (IO::FileExists(jsonFile)) {
            auto json = Json::FromFile(jsonFile);

            print("Read session file at " + jsonFile);

            auto jsonTimes = json.Get("FinishTimes");
            if (jsonTimes.GetType() == Json::Type::Array) {
                for (int i = 0; i < jsonTimes.Length; i++) {
                    if(jsonTimes[i].GetType() == Json::Type::String) {
                        rm.add(DnfRun());
                    }
                    if(jsonTimes[i].GetType() == Json::Type::Number) {
                        rm.add(CompletedRun(PaceTime(this, int(jsonTimes[i]))));
                    }
                }
            }
        }
    }

    void resetData() {
        writeFile(true);
        rm.trackedRuns = array<Run@>();
        rm.setSlice(tab);
        invalidateCache();
    }

    void writeFile(bool toSessionFile = !isDataPersistent) {
        if (mapId != "") {

            auto content = collectJsonContent();

            string jsonFile = "";
            if (toSessionFile) jsonFile = IO::FromStorageFolder(mapId + "_" + Time::FormatString("%Y%m%dT%H%M%S", Time::get_Stamp()) + ".json");
            else jsonFile = IO::FromStorageFolder(mapId + ".json");

            print("Wrote session file to " + jsonFile);

            Json::ToFile(jsonFile, content);
        }
    }
}