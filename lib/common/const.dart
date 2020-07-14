// import 'package:flutter/material.dart';

const kFontSize = 12.0;
// const kImageBorderRadius = Radius.circular(10.0);
const kNavigationBarHeight = 60.0;
const kStorageBucket = 'gs://minsk8-2.appspot.com';
const kGraphQLEndpoint = 'https://minsk8.herokuapp.com/v1/graphql';
const kGraphQLItemsLimit = 11; // заложен +1 для вычисления 'hasMore'
// TODO: нужно проксировать через свой backend на случай отказа в обсуживании.
const kTilesEndpoint = 'https://tilessputnik.ru/{z}/{x}/{y}.png';
const kGoldenRatio = 1.61803;
const kTextMaxLength = 280; // как twitter
const kButtonHeight = 32.0;
const kButtonWidth = kButtonHeight * kGoldenRatio;
const kButtonIconSize = 18.0;
const kDefaultMapCenter = [53.9, 27.56667];
const kBigButtonHeight = 52.0;
const kBigButtonWidth = kBigButtonHeight * kGoldenRatio;
const kBigButtonIconSize = kButtonIconSize * kGoldenRatio;
const kAnimationTime = 400;
const kMinLeadingWidth = 40;
const kGraphQLMutationTimeout = 20;
const kGraphQLQueryTimeout = 20;
const kImageUploadTimeout = 20;
const kAppBarElevation = 4.0; // [AppBar] uses a default value of 4.0.
const kButtonElevation = 2.0;
const kInitialRouteName = '/settings';
