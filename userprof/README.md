# CS 442 MP2: Profile Page

## 1. Overview

For this machine problem you will create a single-screen application that presents a "profile information" page for a user, either yourself or a fictional character, in a hypothetical social networking application. Examples of such apps include professional networking and dating apps.

The primary objective of this MP is to provide you with an opportunity to experiment with various display and layout widgets available in the Flutter framework. Additionally, you should focus on structuring your code in a way that promotes reusability and maintainability.

## 2. Specifications

When executed, your application should display a single scrollable screen containing static user information organized into multiple visually distinct sections. These sections should align with the theme of the hypothetical social networking application. For instance, a professional networking app might feature sections like "Contact," "Education," and "Projects," while a dating app could include "About Me," "Interests," and "My Photos."

The layout and content of the profile page are open to your creative interpretation, but it must adhere to the following requirements:

- Include a minimum of four distinct sections, with each section visually distinguished using nesting, padding, background colors, or similar techniques.

- Incorporate at least three images.

- Utilize at least one nested row/column widget, where each nested widget contains a minimum of two children.

Here's a mockup of what the page might look like (scrolling should be supported, if needed, to view the entire page in the live application):

![Example profile page](assets/images/mp1-mockup.jpg)

Here's a version with blue lines to indicate rows/columns/grids present in the layout.

![Example profile page with layout](assets/images/mp1-mockup-layout.jpg)

## 3. Implementation details / requirements

### 3.1. Project setup

This repository already includes a basic Flutter project structure, which you should use as a starting point for your implementation. You will need to modify the `lib/main.dart` file and create additional Dart files in `lib/` as necessary (e.g., for custom widgets or data model classes -- discussed next).

You should also add any images you wish to use in the app to the `assets/images` directory. See the "Hints / Tips" section below for more details.

### 3.2. User data model

While the layout and content of your finished app will be static (i,e., non-interactive and unchanging), it is good practice nonetheless to structure your code to separate content from layout specifications. In other words, avoid hard-coding data into widgets.

Instead, create one or more classes to represent and store user information, collectively referred to as your *data model*. Pass instances of these classes to your widgets for display. This approach allows you to change the displayed content without altering your widget code.

E.g., for the mockup above, you might define a `UserInfo` class that looks like the following:

```dart
class UserInfo {
  final String name;
  final String position;
  final String company;
  final String phone;
  final String email;
  final String address1;
  final String address2;

  // each entry is a record with named fields that describe a degree
  final List<({String logo, String name, double gpa})> education;

  // each entry is an instance of `ProjectInfo` that contains project details
  final List<ProjectInfo> projects;
  
  // ... constructor, etc.
}
```

Your `main` function, then, might be structured like this:

```dart
void main() {
  // build the user info object
  UserInfo userInfo = UserInfo(
    name: 'John Doe',
    position: 'Software Engineer',
    company: 'ACME Enterprises',
    phone: '(312) 555-1212',
    email: 'john.doe@acme.com',
    address1: '10 W 31st St.'
    address2: 'Chicago, IL 60616'
  );
  userInfo.addEducation(
    logo: 'assets/images/illinois-tech-logo.png',
    name: 'Illinois Tech',
    gpa: 3.8
  );
  // etc.

  // hand the user info object to the root widget
  runApp(MaterialApp(home: UserInfoPage(userInfo: userInfo)));
}
```

Of course, you can create your data model objects elsewhere in your project, but the key is to define them separately from your widget code.

### 3.3. Widget structure

While you have the freedom to experiment with different widget structures, ensure that your widget tree includes **at least one instance of each** of the following widget types (you can include multiple instances of some):

- `AppBar`
- `Column`
- `Container`
- `Image`
- `ListView`
- `MaterialApp`
- `Row`
- `Scaffold`
- `SizedBox`
- `Text`

Optional widgets that you may find useful/interesting:

- `Card`
- `Expanded`
- `GridView`
- `ListTile`
- `SingleChildScrollView`

Although not mandatory, it's highly recommended that you define more than one custom widget class. For example, you can create a `UserInfoPage` widget for the overall page layout and separate widgets for each section or "tile" within a section. This approach will improve code organization and facilitate layout changes.

## 4. Testing

Since the page is static, functional testing is unnecessary. We will evaluate your submission by compiling and running it in a supported Flutter platform (e.g., MacOS, iOS, Android, or web) and visually inspecting the displayed page. We will view the page in a window of at least 1024x768 pixels, so ensure that your layout is legible at that size and has no overflow issues (scrolling is acceptable if needed).

## 5. Grading

This machine problem is worth 28 points, broken down as follows:

- 4 points: A completed `REPORT.md` file with the required information. **Without this we will not evaluate your submission!**

- 8 points: The page layout complies with the specified requirements, and all information is displayed legibly.

- 8 points: Your code structure effectively separates layout from data, involving the use of data model classes and avoiding hardcoding user data within widget implementations.

- 8 points: Your code is well-structured, easy to read, and employs the required widgets and widget structures effectively.

**If your code does not build, you will receive a zero for the assignment.**

## 6. Hints / Tips

- Refer to the "[Layout](https://docs.flutter.dev/ui/layout)" section and "[Building Layouts](https://docs.flutter.dev/ui/layout/tutorial)" tutorial for valuable insights into using various layout widgets.

- To include images in your page, place them in the `assets/images` directory of your project. Ensure that you add and commit them using Git. Displaying them is a matter of constructing `Image` widgets with appropriate paths, like this:
  
  ```dart
  Image.asset('assets/images/my-image.png')
  ```

  See the [Adding assets and images](https://flutter.dev/docs/development/ui/assets-and-images) page in the Flutter documentation for more details.

- Utilize VSCode's "Extract Widget" refactoring tool to assist in isolating sections of your code into separate widget classes. This approach is demonstrated in the "[Your first Flutter app](https://codelabs.developers.google.com/codelabs/flutter-codelab-first#0)" codelab assigned for the previous week.
