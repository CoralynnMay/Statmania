enum Display {
    With_Open_Planet,
    Always_Except_Hidden_UI,
    Always
}

[Setting name="First Tab Count" category="General" description="Number of attempts to keep track of 0 for unlimited"]
uint firstTabCount = 120;

[Setting name="Second Tab Count" category="General" description="Number of attempts to keep track of 0 for unlimited"]
uint secondTabCount = 30;

[Setting name="Third Tab Count" category="General" description="Number of attempts to keep track of 0 for unlimited"]
uint thirdTabCount = 15;

[Setting name="Persist Data" category="General" description="Whether or not stats should follow you into a new session of the track"]
bool isDataPersistent = true;

[Setting name="Enabled" category="UI" description="Whether the plugin is enabled or not"]
bool isEnabled = true;

[Setting name="Lock window location" category="UI" description="Makes the window unmovable"]
bool isWindowLocked = false;

[Setting name="Window Position" category="UI" description="Position of the window, to adjust manually first lock window"]
vec2 anchor = vec2(200, 200);

[Setting name="Display setting" category="UI" description="When to show the window"]
Display displayMode = Display::With_Open_Planet;

[Setting name="Show Map Name" category="UI" description="Shows the map name and author in the window"]
bool showCurrentMapName = true;

[Setting name="Show Mean" category="UI" description="Measure of center, used to see what the most normal run would look like"]
bool showCurrentMean = true;

[Setting name="Show Median" category="UI" description="The center most run in the dataset, used to see your most average time set while accounting  while not being sensitive to outliers"]
bool showCurrentMedian = true;

[Setting name="Show Standard Deviation" category="UI" description="Measure of spread, used for measuring consistency while accounting for outliers"]
bool showCurrentStandardDeviation = true;

[Setting name="Show Mean Absolute Deviation" category="UI" description="Average deviation from the mean, used to measure consistency without accounting for outliers"]
bool showCurrentMAD = true;

[Setting name="Show Interquartile Range" category="UI" description="The center most run in the dataset, used to see your most average time set while accounting  while not being sensitive to outliers"]
bool showCurrentIQR = true;

[Setting name="Show Range" category="UI" description="Range of the center 50% of runs, used to get a sense of spread while reducing effect of outliers"]
bool showCurrentRange = true;

[Setting name="Show Finishes" category="UI" description="The current finish amount"]
bool showCurrentFinishes = true;

[Setting name="Show Last Finish" category="UI" description="The time of the last finish"]
bool showLastFinish = true;

[Setting name="Show Fastest Attempt" category="UI" description="The fastest attempt"]
bool showFastestAttempt = true;

[Setting name="Show Slowest Attempt" category="UI" description="The slowest attempt"]
bool showSlowestAttempt = true;