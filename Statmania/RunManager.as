class RunManager {
    array<Run@> runs;
    array<Run@> trackedRuns;

    void setSlice(int tab) {
        array<Run@> slice = array<Run@>();
        int amount = 0;
        switch(tab) {
            case 1:
                amount = firstTabCount;
                break;
            case 2:
                amount = secondTabCount;
                break;
            case 3:
                amount = thirdTabCount;
                break;
        }

        if (amount < 1) {
            runs = trackedRuns;
            isFinishTimeCacheValid = false;
            isSortedFinishTimeCacheValid = false;
            return;
        }

        if (trackedRuns.Length < amount) {
            runs = trackedRuns;
            isFinishTimeCacheValid = false;
            isSortedFinishTimeCacheValid = false;
            return;
        }

        for (int i = (trackedRuns.Length - amount); i < trackedRuns.Length; i++) {
            slice.InsertLast(trackedRuns[i]);
        }

        runs = slice;
        isFinishTimeCacheValid = false;
        isSortedFinishTimeCacheValid = false;
    }

    array<PaceTime> FinishTimes() {
            if (isFinishTimeCacheValid) return FinishTimesCache;

            auto times = array<PaceTime@>();
            for (int i = 0; i < runs.Length; i++) {
                if (runs[i].type() == RunType::completed) {
                    CompletedRun run = cast<CompletedRun>(runs[i]);
                    times.InsertLast(run.time);
                }
            }
            FinishTimesCache = array<PaceTime>(times.Length);

            for (int i = 0; i < times.Length; i++) {
                FinishTimesCache[i] = times[i];
            }

            isFinishTimeCacheValid = true;

            return FinishTimesCache;
    }

    array<PaceTime> SortedFinishTimes() {
        if (isSortedFinishTimeCacheValid) return SortedFinishTimesCache;

        auto finishTimes = FinishTimes();

        auto SortedFinishTimesCache = array<PaceTime>(finishTimes.Length);

        for (int i = 0; i < finishTimes.Length; i++) {
            SortedFinishTimesCache[i] = finishTimes[i];
        }

        SortedFinishTimesCache.SortAsc();

        return SortedFinishTimesCache;
    }

    private bool isFinishTimeCacheValid;
    private array<PaceTime> FinishTimesCache;
    private bool isSortedFinishTimeCacheValid;
    private array<PaceTime> SortedFinishTimesCache;
    private Session session;

    RunManager(Session session) {
        isFinishTimeCacheValid = false;
        isSortedFinishTimeCacheValid = false;
        this.session = session;
    }

    void add(Run@ run) {
        trackedRuns.InsertLast(run);
        setSlice(session.tab);
        isFinishTimeCacheValid = false;
    }
}