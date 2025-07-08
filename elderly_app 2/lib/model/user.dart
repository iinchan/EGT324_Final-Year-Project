// Elderly user
class User{
  late String? name;
  late String? age;
  late String? gender;
  late String? stayingAlone;
  late String? blockNumber;
  late String? unitNumber;
  late String? postalCode;
  late String? userType;
  late String? assignedCareGiver;
  late DateTime? lastLoginDate;
  late DateTime? lastLogoutDate;
  late String? email;
  late String? phoneNumber;

  User(String name,age,gender,stayingAlone,blockNumber,unitNumber,postalCode,
      userType,assignedcareGiver,lastLogindate,lastLogoutDate,email,phoneNumber){
    this.name = name;
    this.age = age;
    this.gender = gender;
    this.stayingAlone = stayingAlone;
    this.blockNumber = blockNumber;
    this.unitNumber = unitNumber;
    this.postalCode = postalCode;
    this.userType = userType;
    assignedCareGiver = assignedcareGiver;
    lastLoginDate = lastLogindate;
    this.lastLogoutDate = lastLogoutDate;
    this.email = email;
    this.phoneNumber = phoneNumber;
  }

  User.fromJson(Map<String, dynamic> json){
        name = json['Name'];
        age = json['Age'];
        gender = json['Gender'];
        stayingAlone = json['Staying Alone'];
        blockNumber = json['Block Number'];
        unitNumber = json['Unit Number'];
        postalCode = json['Postal Code'];
        userType = json['User Type'];
        assignedCareGiver = json['Assigned CareGiver'];
        lastLoginDate = json['Last Login Date'];
        lastLogoutDate = json['Last Logout Date'];
        email = json['Email'];
        phoneNumber = json['PhoneNumber'];

  }

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Age': age,
    'Gender': gender,
    "Staying Alone": stayingAlone,
    "Block Number": blockNumber,
    "Unit Number": unitNumber,
    "Postal Code": postalCode,
    "UserType": userType,
    "Assigned CareGiver": assignedCareGiver,
    "Last Login Date": lastLoginDate,
    "Last Logout Date": lastLogoutDate,
    "Email": email,
    "PhoneNumber": phoneNumber
  };
}

// Caregiver User
class Care {
  late String? email;
  late String? name;
  late String? phoneNo;
  late String? userType;

  Care(String email, name, phoneNo, userType){
    this.email = email;
    this.name = name;
    this.phoneNo = phoneNo;
    this.userType = userType;
  }

  Care.fromJson(Map<String, dynamic> json){
    email = json["Email"];
    name = json["Name"];
    phoneNo = json["PhoneNumber"];
    userType = json['User Type'];
  }

  Map<String, dynamic> toJson() => {
    "Email": email,
    "Name": name,
    "phoneNo": phoneNo,
    "UserType": userType,
  };
}