class IntCache {
    
    bool isValid {
        get {
            return isValidInternal;
        }
    }

    int value {
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
    protected int internalValue;

    IntCache() {
        isValidInternal = false;
        isValidating = false;
        internalValue = 0;
    }

    void invalidate() {
        isValidInternal = false;
    }

    void validate() {
        isValidInternal = true;
    }
}

class FinishesCache : IntCache {
    private Session session;
    FinishesCache(Session session) {
        this.session = session;
    }

    void validate() override {
        IntCache::validate();
        internalValue = session.rm.FinishTimes().Length;
        isValidating = false;
    }
}

class AttemptsCache : IntCache {
    private Session session;
    AttemptsCache(Session session) {
        this.session = session;
    }

    void validate() override {
        IntCache::validate();
        internalValue = session.rm.runs.Length;
        isValidating = false;
    }
}

class IQRCache : IntCache {
    private Session session;
    IQRCache(Session session) {
        this.session = session;
    }
    void validate() override {
        IntCache::validate();

        auto sorted = session.rm.SortedFinishTimes();

        if (sorted.Length > 3) {
            float flen = float(sorted.Length);
            float center = flen / 2;
            int lowerQuartile = int(Math::Round(center/2));
            int upperQuartile = int(Math::Round(Math::Round(center/2) + center)) - 1;

            internalValue = sorted[upperQuartile].finishTime - sorted[lowerQuartile].finishTime;
        } else {
            internalValue = 0;
        }
        isValidating = false;
    }
}

class RangeCache : IntCache {
    private Session session;
    RangeCache(Session session) {
        this.session = session;
    }
    void validate() override {
        IntCache::validate();

        auto sorted = session.rm.SortedFinishTimes();

        if (sorted.Length > 1) {

            internalValue = sorted[sorted.Length - 1].finishTime - sorted[0].finishTime;
        } else {
            internalValue = 0;
        }
        isValidating = false;
    }
}