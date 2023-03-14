class PaceCache {
    
    bool isValid {
        get {
            return isValidInternal;
        }
    }

    PaceTime value {
        get {
            if (isValid || isValidating) {
                return internalValue;
            } else {
                isValidating = true;
                startnew(CoroutineFunc(validate));
                return internalValue;
            }
        }
    };

    private bool isValidInternal;
    protected bool isValidating;
    protected PaceTime@ internalValue;

    PaceCache() {
        isValidInternal = false;
        isValidating = false;
        @internalValue = PaceTime();
    }

    void invalidate() {
        isValidInternal = false;
    }

    void validate() {
        isValidInternal = true;
    }
}

class MeanPaceCache : PaceCache {
    private Session@ session;
    MeanPaceCache(Session@ session) {
        @this.session = session;
    }

    void validate() override {
        PaceCache::validate();
        int total = 0;
        for (int i = 0; i < session.rm.FinishTimes().Length; i++) {
            total += session.rm.FinishTimes()[i].finishTime;
        }
        if (session.rm.FinishTimes().Length > 0) @internalValue = PaceTime(session, total / int(session.rm.FinishTimes().Length));
        else @internalValue = PaceTime(session, 0);
        isValidating = false;
    }
}

class MedianCache : PaceCache {
    private Session session;
    MedianCache(Session session) {
        this.session = session;
    }

    void validate() override {
        PaceCache::validate();

        auto times = session.rm.SortedFinishTimes();
        if (times.Length > 0 ) @internalValue = times[times.Length/2];
        else @internalValue = PaceTime(session, 0);
        isValidating = false;
    }
}

class LastFinishCache : PaceCache {
    private Session session;
    LastFinishCache(Session session) {
        this.session = session;
    }

    void validate() override {
        PaceCache::validate();
        if (session.rm.FinishTimes().Length > 0 ) @internalValue = session.rm.FinishTimes()[session.rm.FinishTimes().Length - 1];
        else @internalValue = PaceTime(session, 0);
        isValidating = false;
    }
}

class FastestFinishCache : PaceCache {
    private Session session;
    FastestFinishCache(Session session) {
        this.session = session;
    }
    
    void validate() override {
        PaceCache::validate();
        if (session.rm.FinishTimes().Length > 0 ) {
            PaceTime fastest = PaceTime(session, -1);
            for (int i = 0; i < session.rm.FinishTimes().Length; i++) {
                if (fastest.finishTime < 0 || session.rm.FinishTimes()[i].finishTime < fastest.finishTime) fastest = session.rm.FinishTimes()[i];
            }
            @internalValue = fastest;
        }
        else {
            @internalValue = PaceTime(session, 0);
        }
        isValidating = false;
    }
}

class SlowestFinishCache : PaceCache {
    private Session session;
    SlowestFinishCache(Session session) {
        this.session = session;
    }

    void validate() override {
        PaceCache::validate();
        if (session.rm.FinishTimes().Length > 0 ) {
            PaceTime slowest = PaceTime(session, -1);
            for (int i = 0; i < session.rm.FinishTimes().Length; i++) {
                if (slowest.finishTime < 0 || session.rm.FinishTimes()[i].finishTime > slowest.finishTime) slowest = session.rm.FinishTimes()[i];
            }
            @internalValue = slowest;
        }
        else {
            @internalValue = PaceTime(session, 0);
        }
        isValidating = false;
    }
}