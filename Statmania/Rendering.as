bool GLB_cleardataPopUp = false;

void PaceDataRender() {
    UI::SetNextWindowPos(anchor.x, anchor.y, isWindowLocked ? UI::Cond::Always : UI::Cond::FirstUseEver);
    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
    //if (!UI::IsOverlayShown()) windowFlags |= UI::WindowFlags::NoInputs;
    UI::Begin("Statmania", windowFlags);
    if (!isWindowLocked) anchor = UI::GetWindowPos();
        if (showCurrentMapName) {
            UI::BeginTable("header",1,UI::TableFlags::SizingFixedFit);
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$ddd" + GLB_session.mapName);
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$888" + GLB_session.authorName);
            UI::EndTable();
        }
        UI::BeginTabBar("StatmaniaTabs", UI::TabBarFlags::NoCloseWithMiddleMouseButton);
        if (UI::BeginTabItem(Text::Format("%03d", firstTabCount))) {
            GLB_session.updateTabState(1);
            UI::EndTabItem();
        }
        if (UI::BeginTabItem(Text::Format("%03d", secondTabCount))) {
            GLB_session.updateTabState(2);
            UI::EndTabItem();
        }
        if (UI::BeginTabItem(Text::Format("%03d", thirdTabCount))) {
            GLB_session.updateTabState(3);
            UI::EndTabItem();
        }
        UI::EndTabBar();
        UI::BeginGroup();
        UI::BeginTable("Data", 2, UI::TableFlags::SizingFixedFit);
            if (showCurrentMean) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddMean");
                UI::TableNextColumn();
                UI::Text("\\$fff" + formatTime(GLB_session.mean.finishTime));
            }

            if (showCurrentMedian) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddMedian");
                UI::TableNextColumn();
                UI::Text("\\$fff" + formatTime(GLB_session.median.finishTime));
            }

            if (showCurrentStandardDeviation) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddStandard Deviation");
                UI::TableNextColumn();
                UI::Text("\\$0a0 " + Text::Format("%0.3f", GLB_session.StandardDeviation));
            }

            if (showCurrentMAD) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddMean Absolute Deviation");
                UI::TableNextColumn();
                UI::Text("\\$a00 " + Text::Format("%0.3f", GLB_session.MAD));
            }

            if (showCurrentIQR) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddInterquartile Range");
                UI::TableNextColumn();
                UI::Text("\\$0a0 " + formatDeltaTime(GLB_session.IQR));
            }

            if (showCurrentRange) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddRange");
                UI::TableNextColumn();
                UI::Text("\\$a00 " + formatDeltaTime(GLB_session.range));
            }

            if (showCurrentFinishes) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddFinishes");
                UI::TableNextColumn();
                UI::Text("\\$fff" + GLB_session.finishes + "/" + GLB_session.attempts + " \\$0a0"+ Text::Format("%04.1f", GLB_session.finishPercent * 100) + "%");
            }

            if (showLastFinish) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddLast Finish");
                UI::TableNextColumn();
                UI::Text("\\$fff" + formatTime(GLB_session.lastFinish.finishTime));
            }

            if (showFastestAttempt) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddFastest Finish");
                UI::TableNextColumn();
                UI::Text("\\$fff" + formatTime(GLB_session.fastestFinish.finishTime));
            }

            if (showSlowestAttempt) {
                UI::TableNextRow();
                UI::TableNextColumn();
                UI::Text("\\$dddSlowest Finish");
                UI::TableNextColumn();
                UI::Text("\\$fff" + formatTime(GLB_session.slowestFinish.finishTime));
            }
            
        UI::EndTable();
        UI::PushStyleColor(UI::Col::Button, vec4(0.8f, 0.f, 0.f, 1.0f));
        UI::PushStyleColor(UI::Col::ButtonHovered, vec4(0.9f, 0.f, 0.f, 1.0f));
        UI::PushStyleColor(UI::Col::ButtonActive, vec4(0.6f, 0.f, 0.f, 1.0f));
        if (UI::Button(isDataPersistent ? "Clear Data" : "Start New Session")) GLB_cleardataPopUp = true;
        UI::PopStyleColor(3);
        UI::EndGroup();
    UI::End();

    if (GLB_cleardataPopUp) {
        UI::SetNextWindowPos(anchor.x, anchor.y, isWindowLocked ? UI::Cond::Always : UI::Cond::FirstUseEver);
        int popUpWindowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
        UI::Begin("StatmaniaPopUp", popUpWindowFlags);
            UI::Text("This will clear the data from the current session and store it in a session file, no data will be lost, persistent data is not currently importable, are you sure?");
            UI::BeginTable("StatmaniaPopUpAnswers", 2, UI::TableFlags::SizingFixedFit);
                UI::TableNextRow();
                UI::PushStyleColor(UI::Col::Button, vec4(0.8f, 0.f, 0.f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(0.9f, 0.f, 0.f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive, vec4(0.6f, 0.f, 0.f, 1.0f));
                UI::TableNextColumn();
                if (UI::Button("Yes")) {
                    startnew(CoroutineFunc(GLB_session.resetData));
                    GLB_cleardataPopUp = false;
                }
                UI::PopStyleColor(3);
                UI::TableNextColumn();
                if (UI::Button("No")) GLB_cleardataPopUp = false;
            UI::EndTable();
        UI::End();
    }
}

void Render() {
    if (getRenderMode() == RenderMode::Standard) {
        PaceDataRender();
    }
}

void RenderInterface() {
    if (getRenderMode() == RenderMode::Openplanet) {
        PaceDataRender();
    }
}

enum RenderMode {
    Standard,
    Openplanet,
    None
}

RenderMode getRenderMode() {
    if (!isEnabled) return RenderMode::None;

    if (!isOnTrack()) return RenderMode::None;

    if (!GLB_session.started) return RenderMode::None;

    if (displayMode == Display::With_Open_Planet) return RenderMode::Openplanet;

    if (displayMode == Display::Always) return RenderMode::Standard;

    if (displayMode == Display::Always_Except_Hidden_UI) {
        return UI::IsGameUIVisible() ? RenderMode::Standard : RenderMode::None;
    }

    return RenderMode::None;
}

