enum RunType {
    dnf,
    incomplete,
    completed
}

class Run {
    Run() {}

    RunType type() {
        return RunType::dnf;
    }
}

class DnfRun : Run {
    DnfRun() {}

    RunType type() override {
        return RunType::dnf;
    }
}

class IncompleteRun : Run {
    IncompleteRun() {}

    RunType type() override {
        return RunType::incomplete;
    }
}

class CompletedRun : Run {
    PaceTime@ time;

    CompletedRun() {
        @this.time = PaceTime();
    }

    CompletedRun(PaceTime time) {
        @this.time = time;
    }

    RunType type() override {
        return RunType::completed;
    }
}