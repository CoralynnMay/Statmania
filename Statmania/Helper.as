bool isOnTrack() {
    auto app = cast<CTrackMania>(GetApp());

    auto map = app.RootMap;

    if (map is null || map.MapInfo.MapUid == "" || app.Editor !is null) return false;

    if (app.CurrentPlayground is null || app.CurrentPlayground.Interface is null) return false;

    return true;
}

float intTImeToFloatInSeconds(int time) {
    return float(time) / 1000;
}

string formatTime(int time) {
    return Text::Format("%02d", time / 60000)  + ":" + Text::Format("%02d", (time % 60000) / 1000) + "." + Text::Format("%03d", time % 1000);
}

string formatDeltaTime(int time) {
    return Text::Format("%01d", time / 1000) + "." + Text::Format("%03d", time % 1000);
}