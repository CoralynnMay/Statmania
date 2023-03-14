enum Sign {
    positive,
    negative
}

class PaceTime {
    int finishTime;

    int signedDelta {
        get {
            return finishTime - session.mean.finishTime;
        }
    }

    int delta {
        get {
            return Math::Abs(signedDelta);
        }
    }

    Sign deltaSign {
        get {
            return signedDelta > 0 ? Sign::positive : Sign::negative;
        }
    }

    private Session@ session;

    PaceTime() {
        this.finishTime = 0;
        @this.session = GLB_session;
    }

    PaceTime(Session session, int finishTime) {
        this.finishTime = finishTime;
        @this.session = session;
    }

    int opCmp(PaceTime@ other) {
        if (finishTime == other.finishTime) return 0;
        if (finishTime < other.finishTime) return -1;
        return 1;
    }
}