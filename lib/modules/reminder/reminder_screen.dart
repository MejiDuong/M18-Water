import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bottom_sheet/reminder_mode.dart';
import 'reminder_controller.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReminderController>();
    const primaryCyan = Color(0xFF00B9CA);
    const lightBg = Color(0xFFEBECF0);
    const mainText = Colors.black;
    const subText = Colors.grey;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: mainText, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reminder",
              style: TextStyle(color: mainText, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
              "Next: ${controller.nextReminderTime.value} ${controller.timeLeft.value}",
              style: TextStyle(color: mainText, fontSize: 12, fontWeight: FontWeight.normal),
            )),
          ],
        ),
        actions: [
          Obx(() => Switch(
            value: controller.isMasterOn.value,
            onChanged: (val) => controller.toggleMasterSwitch(val),
            activeTrackColor: primaryCyan,
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final isOn = controller.isMasterOn.value;
        return Opacity(
          opacity: isOn ? 1.0 : 0.5,
          child: AbsorbPointer(
            absorbing: !isOn,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildWhiteBlock(child: _buildModeSelector(context, controller, primaryCyan, mainText)),
                  const SizedBox(height: 16),
                  _buildWhiteBlock(child: _buildModeContent(context, controller, primaryCyan, mainText, subText)),
                  const SizedBox(height: 16),
                  _buildWhiteBlock(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildSwitchRow("Weekend Reminder Mode", controller.isWeekendModeOn, primaryCyan, mainText),
                    ),
                  ),
                  if (controller.isWeekendModeOn.value)
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildWhiteBlock(
                          child: controller.currentMode.value == 0
                              ? _buildStandardListUI(context, controller, controller.weekendStandardReminders, primaryCyan, mainText)
                              : (controller.currentMode.value == 1)
                              ? _buildIntervalBlock(
                            context: context,
                            controller: controller,
                            primaryCyan: primaryCyan,
                            mainText: mainText,
                            subText: subText,
                            intervalObs: controller.weekendIntervalDuration,
                            startObs: controller.weekendBedtimeStart,
                            endObs: controller.weekendBedtimeEnd,
                            descriptionTimes: controller.getWeekendIntervalText(),
                          )
                              : _buildCustomModeUI(context, controller, controller.weekendCustomTimes, true, primaryCyan, mainText, subText),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _buildFooter(context, controller, primaryCyan, mainText, subText),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWhiteBlock({required Widget child}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  Widget _buildModeSelector(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText) {
    return InkWell(
      onTap: () => ReminderModeBottomSheet.show(controller),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Reminder Mode", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                Obx(() => Text(controller.currentModeTitle, style: const TextStyle(color: Colors.grey, fontSize: 16))),
                const SizedBox(width: 8),
                const Icon(Icons.edit, color: Colors.grey, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeContent(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText, Color subText) {
    switch (controller.currentMode.value) {
      case 0:
        return _buildStandardListUI(context, controller, controller.standardReminders, primaryCyan, mainText);
      case 1:
        return _buildIntervalBlock(
          context: context,
          controller: controller,
          primaryCyan: primaryCyan,
          mainText: mainText,
          subText: subText,
          intervalObs: controller.intervalDuration,
          startObs: controller.bedtimeStart,
          endObs: controller.bedtimeEnd,
          descriptionTimes: controller.getWeekdayIntervalText(),
        );
      case 2:
        return _buildCustomModeUI(context, controller, controller.customTimes, false, primaryCyan, mainText, subText);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStandardListUI(BuildContext context, ReminderController controller, List<StandardReminder> listToRender, Color primaryCyan, Color mainText) {
    return Column(
      children: listToRender.asMap().entries.map((entry) {
        int index = entry.key;
        var reminder = entry.value;
        bool isLast = index == listToRender.length - 1;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            children: [
              Expanded(child: Text(reminder.name, style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500))),
              GestureDetector(
                onTap: () => _showTimePickerBottomSheet(context, controller, reminder.name, reminder.time, primaryCyan),
                child: Row(
                  children: [
                    Obx(() => Text(reminder.time.value, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500))),
                    const SizedBox(width: 6),
                    const Icon(Icons.edit, color: Colors.grey, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 12),
              Obx(() => Switch(value: reminder.isEnabled.value, onChanged: (val) => reminder.isEnabled.value = val,  activeTrackColor: primaryCyan)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntervalBlock({
    required BuildContext context,
    required ReminderController controller,
    required Color primaryCyan,
    required Color mainText,
    required Color subText,
    required RxString intervalObs,
    required RxString startObs,
    required RxString endObs,
    required String descriptionTimes,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Interval", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () => _showDurationPickerBottomSheet(context, controller, "Interval", intervalObs, primaryCyan),
                  child: Row(
                    children: [
                      Obx(() => Text(intervalObs.value, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 6),
                      Container(width: 1, height: 20, color: Colors.grey.shade300),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit, color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Text("Bedtime", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500))),
                GestureDetector(
                  onTap: () => _showTimePickerBottomSheet(context, controller, "Sleep time start", startObs, primaryCyan),
                  child: Row(
                    children: [
                      Obx(() => Text(startObs.value, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: Colors.grey, size: 14),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("to", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                ),
                GestureDetector(
                  onTap: () => _showTimePickerBottomSheet(context, controller, "Sleep time end", endObs, primaryCyan),
                  child: Row(
                    children: [
                      Obx(() => Text(endObs.value, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500))),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: Colors.grey, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(() => RichText(
            text: TextSpan(
              style: TextStyle(color: subText, fontSize: 13, height: 1.5),
              children: [
                const TextSpan(text: "We'll remind you every "),
                TextSpan(
                  text: intervalObs.value,
                  style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w500),
                ),
                const TextSpan(text: " during your active time:\n"),
                TextSpan(
                  text: descriptionTimes,
                  style: TextStyle(color: subText, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCustomModeUI(BuildContext context, ReminderController controller, List<CustomTime> listToRender, bool isWeekend, Color primaryCyan, Color mainText, Color subText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text("Time (${listToRender.length}/30)", style: TextStyle(color: mainText, fontSize: 14, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 2),
                  Text("Hold the tag to edit", style: TextStyle(color: subText, fontSize: 12)),
                ],
              ),
              Obx(() {
                int selectedCount = listToRender.where((e) => e.isEnabled.value).length;
                return Text("$selectedCount Selected", style: TextStyle(color: subText, fontSize: 14));
              }),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...listToRender.map((item) {
                return Obx(() {
                  bool isOn = item.isEnabled.value;
                  return GestureDetector(
                    onTap: () {
                      item.isEnabled.value = !item.isEnabled.value;
                      controller.refreshData(); // Lưu và nạp lại báo thức
                    },
                    onLongPress: () => _showTimerBottomSheet(context, controller, primaryCyan, existingItem: item, isWeekend: isWeekend),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isOn ? primaryCyan : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          item.time.value,
                          style: TextStyle(
                              color: isOn ? Colors.white : const Color(0xFF8E8E93),
                              fontSize: 13,
                              fontWeight: FontWeight.w600
                          )
                      ),
                    ),
                  );
                });
              }),
              if (listToRender.length < 30)
                GestureDetector(
                  onTap: () => _showTimerBottomSheet(context, controller, primaryCyan, isWeekend: isWeekend),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF8E8E93), size: 18),
                  ),
                ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ReminderController controller, Color primaryCyan, Color mainText, Color subText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text("Skip & Stop", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        _buildWhiteBlock(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildSwitchRow("Stop when goal achieved", controller.stopWhenGoalAchieved, primaryCyan, mainText),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text("Smart Skip", style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500))),
                    GestureDetector(
                      onTap: () => _showDurationPickerBottomSheet(context, controller, "Smart Skip", controller.smartSkipDuration, primaryCyan, isSmartSkip: true),
                      child: Row(
                        children: [
                          Obx(() => Text(controller.smartSkipDuration.value, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500))),
                          const SizedBox(width: 6),
                          Container(width: 1, height: 24, color: Colors.grey.shade300),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => Switch(value: controller.isSmartSkipOn.value, onChanged: (val) => controller.isSmartSkipOn.value = val,  activeTrackColor: primaryCyan)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDurationPickerBottomSheet(BuildContext context, ReminderController controller, String title, RxString targetObs, Color primaryCyan, {bool isSmartSkip = false}) {
    bool tempIsOn = isSmartSkip ? controller.isSmartSkipOn.value : true;
    String tempDuration = targetObs.value;

    final List<String> options = isSmartSkip
        ? ["50 min", "1 hour", "1.5 hours", "2 hours", "2.5 hours", "3 hours"]
        : ["30 min", "1 hour", "1.5 hours", "2 hours", "3 hours", "4 hours"];

    int initialIndex = options.indexOf(tempDuration);
    if (initialIndex == -1) {
      options.add(tempDuration);
      initialIndex = options.length - 1;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        if (isSmartSkip) // Chỉ hiện công tắc nếu là Smart Skip
                          Switch(
                            value: tempIsOn,
                            onChanged: (val) => setState(() => tempIsOn = val),
                            activeTrackColor: primaryCyan,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 150,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialIndex),
                        itemExtent: 45,
                        selectionOverlay: Container(
                          decoration: BoxDecoration(
                            border: Border.symmetric(horizontal: BorderSide(color: primaryCyan, width: 1.5)),
                          ),
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() => tempDuration = options[index]);
                        },
                        children: options.map((option) {
                          final isSelected = option == tempDuration;
                          return Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? primaryCyan : Colors.grey.shade400,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isSmartSkip)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                            children: [
                              const TextSpan(text: "After recording a drink, the "),
                              TextSpan(
                                text: "next $tempDuration reminder\n",
                                style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: "will be canceled."),
                            ],
                          ),
                        ),
                      ),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: primaryCyan, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text("Cancel", style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (isSmartSkip) controller.isSmartSkipOn.value = tempIsOn;
                              targetObs.value = tempDuration;
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: primaryCyan,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  void _showTimePickerBottomSheet(BuildContext context, ReminderController controller, String title, RxString timeObs, Color primaryCyan) {
    List<String> parts = timeObs.value.split(' ');
    List<String> hm = parts[0].split(':');
    int tempHour = int.parse(hm[0]);
    int tempMin = int.parse(hm[1]);
    String tempAmPm = parts.length > 1 ? parts[1] : "AM";

    final List<String> hoursList = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
    final List<String> minutesList = List.generate(60, (index) => index.toString().padLeft(2, '0'));
    final List<String> amPmList = ["AM", "PM"];

    int tempHourIndex = tempHour - 1;
    int tempMinIndex = tempMin;
    int tempAmPmIndex = tempAmPm == "AM" ? 0 : 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        Switch(
                          value: true,
                          onChanged: (val) {},
                          activeTrackColor: primaryCyan,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 45,
                            width: 220,
                            decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade200, width: 1.5))),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: tempHourIndex),
                                  itemExtent: 45,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (index) => setState(() => tempHourIndex = index),
                                  children: hoursList.asMap().entries.map((entry) {
                                    bool isSelected = entry.key == tempHourIndex;
                                    return Center(child: Text(entry.value, style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryCyan : Colors.grey.shade400)));
                                  }).toList(),
                                ),
                              ),
                              Text(" : ", style: TextStyle(color: primaryCyan, fontSize: 24, fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 60,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: tempMinIndex),
                                  itemExtent: 45,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (index) => setState(() => tempMinIndex = index),
                                  children: minutesList.asMap().entries.map((entry) {
                                    bool isSelected = entry.key == tempMinIndex;
                                    return Center(child: Text(entry.value, style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryCyan : Colors.grey.shade400)));
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: tempAmPmIndex),
                                  itemExtent: 45,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (index) => setState(() => tempAmPmIndex = index),
                                  children: amPmList.asMap().entries.map((entry) {
                                    bool isSelected = entry.key == tempAmPmIndex;
                                    return Center(child: Text(entry.value, style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryCyan : Colors.grey.shade400)));
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: primaryCyan, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: Text("Cancel", style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              String finalTime = "${hoursList[tempHourIndex]}:${minutesList[tempMinIndex]} ${amPmList[tempAmPmIndex]}";
                              timeObs.value = finalTime;
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: primaryCyan, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  Widget _buildSwitchRow(String title, RxBool obsValue, Color primaryCyan, Color mainText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: mainText, fontSize: 16, fontWeight: FontWeight.w500)),
        Obx(() => Switch(value: obsValue.value, onChanged: (val) => obsValue.value = val, activeTrackColor: primaryCyan)),
      ],
    );
  }

  // GIAO DIỆN BOTTOM SHEET TIMER (CÓ BẮT LỖI)
  void _showTimerBottomSheet(BuildContext context, ReminderController controller, Color primaryCyan, {CustomTime? existingItem, bool isWeekend = false}) {
    String initialTime = existingItem != null ? existingItem.time.value : "08:00 AM";
    List<String> parts = initialTime.split(' ');
    List<String> hm = parts[0].split(':');
    int tempHour = int.parse(hm[0]);
    int tempMin = int.parse(hm[1]);
    String tempAmPm = parts.length > 1 ? parts[1] : "AM";

    final List<String> hoursList = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
    final List<String> minutesList = List.generate(60, (index) => index.toString().padLeft(2, '0'));
    final List<String> amPmList = ["AM", "PM"];

    int tempHourIndex = tempHour - 1;
    int tempMinIndex = tempMin;
    int tempAmPmIndex = tempAmPm == "AM" ? 0 : 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Timer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        // NÚT THÙNG RÁC (CÓ LOGIC CHẶN XÓA HẾT)
                        InkWell(
                          onTap: () {
                            if (existingItem != null) {
                              var targetList = isWeekend ? controller.weekendCustomTimes : controller.customTimes;

                              // [MỚI] CHẶN NẾU CHỈ CÒN ĐÚNG 1 CÁI BÁO THỨC
                              if (targetList.length <= 1) {
                                Get.back();
                                _showCustomError("You cannot delete all alarms. Please add more.");
                                return; // Dừng lại, không xóa
                              }

                              targetList.remove(existingItem);
                              controller.refreshData();
                            }
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.black87, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 45,
                            width: 220,
                            decoration: BoxDecoration(
                                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade200, width: 1.5))
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: tempHourIndex),
                                  itemExtent: 45,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (index) => setState(() => tempHourIndex = index),
                                  children: hoursList.asMap().entries.map((entry) {
                                    bool isSelected = entry.key == tempHourIndex;
                                    return Center(child: Text(entry.value, style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryCyan : Colors.grey.shade400)));
                                  }).toList(),
                                ),
                              ),
                              Text(" : ", style: TextStyle(color: primaryCyan, fontSize: 24, fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 60,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: tempMinIndex),
                                  itemExtent: 45,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (index) => setState(() => tempMinIndex = index),
                                  children: minutesList.asMap().entries.map((entry) {
                                    bool isSelected = entry.key == tempMinIndex;
                                    return Center(child: Text(entry.value, style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryCyan : Colors.grey.shade400)));
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(initialItem: tempAmPmIndex),
                                  itemExtent: 45,
                                  selectionOverlay: null,
                                  onSelectedItemChanged: (index) => setState(() => tempAmPmIndex = index),
                                  children: amPmList.asMap().entries.map((entry) {
                                    bool isSelected = entry.key == tempAmPmIndex;
                                    return Center(child: Text(entry.value, style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primaryCyan : Colors.grey.shade400)));
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: primaryCyan, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: Text("Cancel", style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // NÚT SAVE (CÓ LOGIC CHẶN TRÙNG LẶP)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              String finalTime = "${hoursList[tempHourIndex]}:${minutesList[tempMinIndex]} ${amPmList[tempAmPmIndex]}";
                              var targetList = isWeekend ? controller.weekendCustomTimes : controller.customTimes;
                              bool isDuplicate = targetList.any((e) => e.time.value == finalTime && e != existingItem);
                              if (isDuplicate) {
                                Get.back();
                                _showCustomError("This alarm is already set.");
                                return; // Dừng lại, không cho save
                              }
                              if (existingItem != null) {
                                existingItem.time.value = finalTime;
                              } else {
                                var newItem = CustomTime(time: finalTime, isEnabled: true);
                                targetList.add(newItem);
                              }
                              controller.refreshData();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: primaryCyan, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  void _showCustomError(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.rawSnackbar(
      messageText: Row(
        children: [
          const Icon(Icons.cancel, color: Color(0xFFF44336), size: 24), // Icon tròn đỏ có dấu x
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      borderRadius: 30,
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      snackPosition: SnackPosition.TOP,
      borderColor: const Color(0xFFF44336),
      borderWidth: 1.5,
      boxShadows: [const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      duration: const Duration(seconds: 3),
    );
  }
}