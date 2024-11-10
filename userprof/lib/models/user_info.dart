// UserInfo class to represent a user's profile information
class UserInfo {
  String name;
  String position;
  String company;
  String phone;
  String email;
  String address1;
  String address2;
  List<Education> education;
  List<ProjectInfo> projects;

  // Constructor for UserInfo
  UserInfo({
    required this.name,
    required this.position,
    required this.company,
    required this.phone,
    required this.email,
    required this.address1,
    required this.address2,
    required this.education,
    required this.projects,
  });

  // Static method to create a dummy UserInfo instance for testing or placeholder data
  static UserInfo createDummy() {
    return UserInfo(
      name: 'John Doe',
      position: 'Software Engineer',
      company: 'ACME Enterprises',
      phone: '(312) 555-1212',
      email: 'john.doe@acme.com',
      address1: '10 W 31st St.',
      address2: 'Chicago, IL 60616',
      education: [
        Education(logo: 'assets/images/illinois.png', name: 'Illinois Tech', degree: 'BS in CS', gpa: 3.8),
        Education(logo: 'assets/images/vidya.png', name: 'Vidya Jyothi', degree: '', gpa: 3.2)
      ],
      projects: [
        ProjectInfo(name: 'EcoTrack', description: 'Mobile app for tracking personal carbon footprint'),
        ProjectInfo(name: 'MindfulMinutes', description: 'Meditation and mindfulness web application'),
        ProjectInfo(name: 'SmartHome Hub', description: 'IoT platform for home automation and energy management'),
        ProjectInfo(name: 'HealthBuddy', description: 'AI-powered health assistant and symptom checker'),
        ProjectInfo(name: 'CodeCollab', description: 'Real-time collaborative IDE for remote development teams'),
        ProjectInfo(name: 'ArtisanMarket', description: 'E-commerce platform connecting artisans with global customers'),
      ],
    );
  }
}

// Education class to represent a user's educational background
class Education {
  String logo;    // Path to the institution's logo image
  String name;    // Name of the educational institution
  double gpa;     // Grade Point Average
  String degree;  // Degree obtained or course of study

  // Constructor for Education
  Education({required this.logo, required this.name, required this.degree, required this.gpa});
}

// ProjectInfo class to represent information about a user's project
class ProjectInfo {
  String name;        // Name of the project
  String description; // Brief description of the project

  // Constructor for ProjectInfo
  ProjectInfo({required this.name, required this.description});
}