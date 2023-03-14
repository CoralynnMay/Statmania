class FloatCache {
    
    bool isValid {
        get {
            return isValidInternal;
        }
    }

    float value {
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
    protected float internalValue;

    FloatCache() {
        isValidInternal = false;
        isValidating = false;
        internalValue = 0.f;
    }

    void invalidate() {
        isValidInternal = false;
    }

    void validate() {
        isValidInternal = true;
    }
}

class FinishesPercentCache : FloatCache {
    private Session session;
    FinishesPercentCache(Session session) {
        this.session = session;
    }

    void validate() override {
        FloatCache::validate();
        
        if (session.attempts != 0) internalValue = float(session.finishes) / float(session.attempts);
        else internalValue = 0;
        isValidating = false;
    }
}

class StandardDeviationCache : FloatCache {
    private Session session;
    StandardDeviationCache(Session session) {
        this.session = session;
    }

    void validate() override {
        FloatCache::validate();
        
        auto times = session.rm.FinishTimes();

        if (times.Length > 1) {
            float mean = intTImeToFloatInSeconds(session.mean.finishTime);
            
            float summation = 0.f;
            for (int i = 0; i < times.Length; i++) {
                summation += Math::Pow((intTImeToFloatInSeconds(times[i].finishTime) - mean), 2.f);
            }

            internalValue = Math::Sqrt(summation / float(times.Length - 1));
            isValidating = false;
        }
    }
}

class MADCache : FloatCache {
    private Session session;
    MADCache(Session session) {
        this.session = session;
    }

    void validate() override {
        FloatCache::validate();
        
        auto times = session.rm.FinishTimes();

        if (times.Length > 1) {
            float mean = intTImeToFloatInSeconds(session.mean.finishTime);
            
            float summation = 0.f;
            for (int i = 0; i < times.Length; i++) {
                summation += Math::Abs((intTImeToFloatInSeconds(times[i].finishTime) - mean));
            }

            internalValue = summation / float(times.Length);
        }
        isValidating = false;
    }
}