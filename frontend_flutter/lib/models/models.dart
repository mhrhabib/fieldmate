// Mirrors backend/app/models.py — keep these in sync manually for now.
// (Once the API stabilizes, consider generating this from the OpenAPI schema
// FastAPI already exposes at /openapi.json.)

enum JobStatus {
  lead,
  scheduled,
  inProgress,
  waitingOnPart,
  completed,
  invoiced,
  paid;

  static JobStatus fromApi(String value) {
    switch (value) {
      case 'lead':
        return JobStatus.lead;
      case 'scheduled':
        return JobStatus.scheduled;
      case 'in_progress':
        return JobStatus.inProgress;
      case 'waiting_on_part':
        return JobStatus.waitingOnPart;
      case 'completed':
        return JobStatus.completed;
      case 'invoiced':
        return JobStatus.invoiced;
      case 'paid':
        return JobStatus.paid;
    }
    throw ArgumentError('Unknown JobStatus: $value');
  }

  String toApi() {
    switch (this) {
      case JobStatus.lead:
        return 'lead';
      case JobStatus.scheduled:
        return 'scheduled';
      case JobStatus.inProgress:
        return 'in_progress';
      case JobStatus.waitingOnPart:
        return 'waiting_on_part';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.invoiced:
        return 'invoiced';
      case JobStatus.paid:
        return 'paid';
    }
  }

  String get label {
    switch (this) {
      case JobStatus.lead:
        return 'Lead';
      case JobStatus.scheduled:
        return 'Scheduled';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.waitingOnPart:
        return 'Waiting on Part';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.invoiced:
        return 'Invoiced';
      case JobStatus.paid:
        return 'Paid';
    }
  }

  // The status a "Next" button should move a job to. Null means terminal.
  JobStatus? get next {
    switch (this) {
      case JobStatus.lead:
        return JobStatus.scheduled;
      case JobStatus.scheduled:
        return JobStatus.inProgress;
      case JobStatus.inProgress:
        return JobStatus.completed;
      case JobStatus.waitingOnPart:
        return JobStatus.inProgress;
      case JobStatus.completed:
        return JobStatus.invoiced;
      case JobStatus.invoiced:
        return JobStatus.paid;
      case JobStatus.paid:
        return null;
    }
  }
}

class Customer {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  Customer({this.id, required this.name, required this.phone, this.email, this.address});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      };
}

class Job {
  final int? id;
  final int customerId;
  final String applianceType;
  final String? brand;
  final String? modelNumber;
  final String? serialNumber;
  final String symptom;
  final String? diagnosis;
  final JobStatus status;
  final String? notes;
  final String? partNeeded;
  final int? originalJobId;

  Job({
    this.id,
    required this.customerId,
    required this.applianceType,
    this.brand,
    this.modelNumber,
    this.serialNumber,
    required this.symptom,
    this.diagnosis,
    this.status = JobStatus.lead,
    this.notes,
    this.partNeeded,
    this.originalJobId,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'],
        customerId: json['customer_id'],
        applianceType: json['appliance_type'],
        brand: json['brand'],
        modelNumber: json['model_number'],
        serialNumber: json['serial_number'],
        symptom: json['symptom'],
        diagnosis: json['diagnosis'],
        status: JobStatus.fromApi(json['status']),
        notes: json['notes'],
        partNeeded: json['part_needed'],
        originalJobId: json['original_job_id'],
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'appliance_type': applianceType,
        if (brand != null) 'brand': brand,
        if (modelNumber != null) 'model_number': modelNumber,
        if (serialNumber != null) 'serial_number': serialNumber,
        'symptom': symptom,
        if (diagnosis != null) 'diagnosis': diagnosis,
        'status': status.toApi(),
        if (notes != null) 'notes': notes,
        if (partNeeded != null) 'part_needed': partNeeded,
        if (originalJobId != null) 'original_job_id': originalJobId,
      };
}
