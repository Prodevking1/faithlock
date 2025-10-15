class PostHogEvent {
  final String name;
  final Map<String, dynamic> properties;
  final String? distinctId;
  final DateTime timestamp;
  final String? sessionId;
  final Map<String, dynamic>? userProperties;

   PostHogEvent({
    required this.name,
    required this.properties,
    this.distinctId,
    DateTime? timestamp,
    this.sessionId,
    this.userProperties,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'event': name,
      'properties': {
        ...properties,
        if (sessionId != null) 'session_id': sessionId,
        'timestamp': timestamp.toIso8601String(),
      },
      if (distinctId != null) 'distinct_id': distinctId,
      if (userProperties != null) 'user_properties': userProperties,
    };
  }

  factory PostHogEvent.fromJson(Map<String, dynamic> json) {
    return PostHogEvent(
      name: json['event'] as String,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      distinctId: json['distinct_id'] as String?,
      timestamp: DateTime.parse(json['properties']['timestamp'] as String),
      sessionId: json['properties']['session_id'] as String?,
      userProperties: json['user_properties'] != null
          ? Map<String, dynamic>.from(json['user_properties'])
          : null,
    );
  }

  PostHogEvent copyWith({
    String? name,
    Map<String, dynamic>? properties,
    String? distinctId,
    DateTime? timestamp,
    String? sessionId,
    Map<String, dynamic>? userProperties,
  }) {
    return PostHogEvent(
      name: name ?? this.name,
      properties: properties ?? this.properties,
      distinctId: distinctId ?? this.distinctId,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      userProperties: userProperties ?? this.userProperties,
    );
  }

  @override
  String toString() {
    return 'PostHogEvent(name: $name, properties: $properties, distinctId: $distinctId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostHogEvent &&
        other.name == name &&
        other.distinctId == distinctId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return name.hashCode ^ distinctId.hashCode ^ timestamp.hashCode;
  }
}

class PostHogUserProfile {
  final String distinctId;
  final Map<String, dynamic> properties;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final String? email;
  final String? name;
  final String? avatar;
  final List<String> segments;

   PostHogUserProfile({
    required this.distinctId,
    required this.properties,
    this.createdAt,
    DateTime? updatedAt,
    this.email,
    this.name,
    this.avatar,
    this.segments = const [],
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'distinct_id': distinctId,
      'properties': {
        ...properties,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (avatar != null) 'avatar': avatar,
        'segments': segments,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      },
    };
  }

  factory PostHogUserProfile.fromJson(Map<String, dynamic> json) {
    final props = Map<String, dynamic>.from(json['properties'] ?? {});
    return PostHogUserProfile(
      distinctId: json['distinct_id'] as String,
      properties: props,
      createdAt: props['created_at'] != null
          ? DateTime.parse(props['created_at'] as String)
          : null,
      updatedAt: props['updated_at'] != null
          ? DateTime.parse(props['updated_at'] as String)
          : DateTime.now(),
      email: props['email'] as String?,
      name: props['name'] as String?,
      avatar: props['avatar'] as String?,
      segments: List<String>.from(props['segments'] ?? []),
    );
  }

  PostHogUserProfile copyWith({
    String? distinctId,
    Map<String, dynamic>? properties,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? email,
    String? name,
    String? avatar,
    List<String>? segments,
  }) {
    return PostHogUserProfile(
      distinctId: distinctId ?? this.distinctId,
      properties: properties ?? this.properties,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      segments: segments ?? this.segments,
    );
  }
}

class PostHogCampaignData {
  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmTerm;
  final String? utmContent;
  final String? referrer;
  final String? clickId;
  final DateTime? attributionTimestamp;

  const PostHogCampaignData({
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmTerm,
    this.utmContent,
    this.referrer,
    this.clickId,
    this.attributionTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      if (utmSource != null) 'utm_source': utmSource,
      if (utmMedium != null) 'utm_medium': utmMedium,
      if (utmCampaign != null) 'utm_campaign': utmCampaign,
      if (utmTerm != null) 'utm_term': utmTerm,
      if (utmContent != null) 'utm_content': utmContent,
      if (referrer != null) 'referrer': referrer,
      if (clickId != null) 'click_id': clickId,
      if (attributionTimestamp != null)
        'attribution_timestamp': attributionTimestamp!.toIso8601String(),
    };
  }

  factory PostHogCampaignData.fromJson(Map<String, dynamic> json) {
    return PostHogCampaignData(
      utmSource: json['utm_source'] as String?,
      utmMedium: json['utm_medium'] as String?,
      utmCampaign: json['utm_campaign'] as String?,
      utmTerm: json['utm_term'] as String?,
      utmContent: json['utm_content'] as String?,
      referrer: json['referrer'] as String?,
      clickId: json['click_id'] as String?,
      attributionTimestamp: json['attribution_timestamp'] != null
          ? DateTime.parse(json['attribution_timestamp'] as String)
          : null,
    );
  }

  bool get hasAttribution {
    return utmSource != null ||
        utmMedium != null ||
        utmCampaign != null ||
        referrer != null;
  }

  Map<String, dynamic> get attributionProperties {
    final props = <String, dynamic>{};
    if (hasAttribution) {
      props.addAll(toJson());
    }
    return props;
  }
}
