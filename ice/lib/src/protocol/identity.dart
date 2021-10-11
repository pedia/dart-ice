part of ice.protocol;

///
/// The identity of an Ice object. In a proxy, an empty [Identity.name] denotes a nil
/// proxy. An identity with an empty  [Identity.name] and a non-empty [Identity.category]
/// is illegal. You cannot add a servant with an empty name to the Active Servant Map.
///
/// @see [ServantLocator],
/// @see [ObjectAdapter.addServantLocator]
class Identity {
  /// The name of the Ice object.
  final String name;

  /// The Ice object category.
  final String category;

  Identity({this.name = '', this.category = ''});

  @override
  String toString() {
    if (category.isNotEmpty) {
      return '$category/$name';
    } else {
      return name;
    }
  }

  @override
  int get hashCode => Object.hash(category, name);

  @override
  bool operator ==(Object other) {
    return other is Identity &&
        category == other.category &&
        name == other.name;
  }

  bool get isEmpty => name.isEmpty && category.isEmpty;
}

typedef ObjectDict = Map<Identity, Object>;

typedef IdentitySeq = List<Identity>;
