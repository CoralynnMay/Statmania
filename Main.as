Session GLB_session = Session();
bool needNewSession = true;

void Main() {
    while(true) {
        if (needNewSession && isOnTrack()) {
            needNewSession = false;
            GLB_session = Session();
            GLB_session.start();
        }

        if (!needNewSession && !isOnTrack()) {
            needNewSession = true;
        }
        yield();
    }
}

