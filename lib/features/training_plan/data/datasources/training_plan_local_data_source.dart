import '../../../../core/data/persistence_json.dart';
import '../../../../objectbox.g.dart';
import '../../../profile/data/datasources/objectbox_data_source.dart';
import '../../../profile/data/models/profile_box_entity.dart';
import '../models/training_plan_entity.dart';

class TrainingPlanLocalDataSource {
  TrainingPlanLocalDataSource({Store? store})
    : _store = store ?? MotionOrbitObjectBox.store;

  static const initializedKey = 'storage/training_plans_initialized';
  final Store _store;
  Box<TrainingPlanEntity> get _box => _store.box<TrainingPlanEntity>();
  Box<TrainingPlanActivityEntity> get _activities =>
      _store.box<TrainingPlanActivityEntity>();

  ProfileBoxEntity? _initialization() {
    final query = _store.box<ProfileBoxEntity>()
        .query(ProfileBoxEntity_.key.equals(initializedKey)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  void markInitialized() {
    final previous = _initialization();
    _store.box<ProfileBoxEntity>().put(ProfileBoxEntity(
      id: previous?.id ?? 0, key: initializedKey, value: '1',
    ));
  }

  TrainingPlanEntity? _find(String id) {
    final query = _box.query(TrainingPlanEntity_.businessId.equals(id)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  List<TrainingPlanActivityEntity> _children(int id) {
    final query = _activities.query(
        TrainingPlanActivityEntity_.plan.equals(id)).build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  Map<String, dynamic>? readPlan(String id) {
    final plan = _find(id);
    if (plan == null) return null;
    return plan.toJson(_children(plan.id));
  }

  List<Map<String, dynamic>>? readPlans() {
    final plans = _box.getAll()..sort((a, b) => a.position.compareTo(b.position));
    if (plans.isEmpty && _initialization() == null) return null;
    return [for (final plan in plans) plan.toJson(_children(plan.id))];
  }

  Map<String, int> readPlanTypeCounts() {
    final counts = <String, int>{'All': _box.count()};
    for (final plan in _box.getAll()) {
      counts.update(plan.type, (count) => count + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  /// Called inside a write transaction, including during startup migration.
  void putPlan(TrainingPlanRecord record) {
    final previous = _find(record.plan.businessId);
    record.plan.id = previous?.id ?? 0;
    _box.put(record.plan);
    final oldChildren = {
      for (final child in _children(record.plan.id)) child.recordKey: child,
    };
    for (final child in record.activities) {
      child.id = oldChildren.remove(child.recordKey)?.id ?? 0;
      child.plan.targetId = record.plan.id;
      _activities.put(child);
    }
    _activities.removeMany(oldChildren.values.map((child) => child.id).toList());
  }

  void _deletePlan(String businessId) {
    final plan = _find(businessId);
    if (plan == null) return;
    _activities.removeMany(_children(plan.id).map((child) => child.id).toList());
    _box.remove(plan.id);
  }

  int _nextPosition() {
    final query = (_box.query()
        ..order(TrainingPlanEntity_.position, flags: Order.descending)).build();
    try {
      return (query.findFirst()?.position ?? -1) + 1;
    } finally {
      query.close();
    }
  }

  /// Update only the specified plans and their children. Other plans are not
  /// loaded or rewritten when a single plan is edited or deleted.
  void applyChanges({required List<Map<String, dynamic>> upserts,
      required List<String> deletedIds}) {
    PersistenceJson.uniqueIds(upserts, 'training/plans');
    final records = [for (final json in upserts)
      TrainingPlanRecord.fromJson(json, 0)];
    _store.runInTransaction(TxMode.write, () {
      for (final id in deletedIds) {
        _deletePlan(id);
      }
      for (var i = 0; i < records.length; i++) {
        // Keep gaps after deletion. Appending uses the largest stored ordinal,
        // so no other plan needs to be rewritten to maintain a stable order.
        records[i].plan.position =
            _find(records[i].plan.businessId)?.position ?? _nextPosition();
        putPlan(records[i]);
        PersistenceJson.confirm(upserts[i], readPlan(records[i].plan.businessId),
            'training/plans/${records[i].plan.businessId}');
      }
      markInitialized();
    });
  }

  /// Full replacement is reserved for explicit bulk/seed operations.
  void writePlans(List<Map<String, dynamic>> plans) {
    PersistenceJson.uniqueIds(plans, 'training/plans');
    final records = [for (var i = 0; i < plans.length; i++)
      TrainingPlanRecord.fromJson(plans[i], i)];
    final ids = plans.map((plan) => PersistenceJson.businessId(plan)).toSet();
    _store.runInTransaction(TxMode.write, () {
      for (final previous in _box.getAll()) {
        if (!ids.contains(previous.businessId)) _deletePlan(previous.businessId);
      }
      for (final record in records) {
        putPlan(record);
      }
      markInitialized();
      PersistenceJson.confirm(plans, readPlans(), 'training/plans');
    });
  }
}
