import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSvgIcon {
  ProfileSvgIcon._();

  static const _basePath = 'assets/profile/icons';

  static const status = '$_basePath/status_indicator.svg';
  static const edit = '$_basePath/edit.svg';
  static const beginner = '$_basePath/beginner.svg';
  static const goal = '$_basePath/goal.svg';
  static const offline = '$_basePath/offline.svg';
  static const weight = '$_basePath/weight.svg';
  static const height = '$_basePath/height.svg';
  static const workout = '$_basePath/workout.svg';
  static const trend = '$_basePath/trend.svg';
  static const flame = '$_basePath/flame.svg';
  static const personalInformation = '$_basePath/personal_information.svg';
  static const fitnessAssessment = '$_basePath/fitness_assessment.svg';
  static const bodyMeasurements = '$_basePath/body_measurements.svg';
  static const progress = '$_basePath/progress.svg';
  static const goals = '$_basePath/goals.svg';
  static const settings = '$_basePath/settings.svg';
  static const chevronRight = '$_basePath/chevron_right.svg';
  static const home = '$_basePath/home.svg';
  static const training = '$_basePath/training.svg';
  static const explore = '$_basePath/explore.svg';
  static const profile = '$_basePath/profile.svg';

  static SvgPicture asset(String path) =>
      SvgPicture.asset(path, fit: BoxFit.contain);
}
