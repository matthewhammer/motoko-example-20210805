import Prelude "mo:base/Prelude";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Trie "mo:base/Trie";
import TrieMap "mo:base/TrieMap";

// import non-base primitives
import Rel "Rel";
import RelObj "RelObj";
import SeqObj "SeqObj";

// types in separate file
import Types "Types";

/// Internal CanCan canister state.
module {

  // Our representation of (binary) relations.
  public type RelShared<X, Y> = Rel.RelShared<X, Y>;
  public type Rel<X, Y> = RelObj.RelObj<X, Y>;

  // Our representation of finite mappings.
  public type MapShared<X, Y> = Trie.Trie<X, Y>;
  public type Map<X, Y> = TrieMap.TrieMap<X, Y>;

  /// State.
  ///
  /// Not a shared type because of OO containers and HO functions.
  /// So, cannot directly send in messages or store in stable memory.
  /// But the API is nicer to use, and we can extract data to send/store.
  ///
  public type State = {

    // === Main entities ===

    /// all users (including hosts).
    users : Map<Types.User.Id, Types.User.User>;

    /// all hosts (extra data from user data).
    hosts : Map<Types.Host.Id, Types.Host.Host>;

    /// all posts.
    posts : Map<Types.Post.Id, Types.Post.Post>;

    /// all xchanges.
    xchanges : Map<Types.Xchange.Id, Types.Xchange.Xchange>;

    // to do: Threads, Discourses

    // === Binary relations (relating entities) ===

    /// userFollows relation relates each user with those whom they follow.
    userFollows : Rel<Types.User.Id, Types.User.Id>;

    /// userPosts relation relates each user with those posts that they publish.
    userPosts : Rel<Types.User.Id, Types.Post.Id>;

    /// xchangePosts relation relates each xchange its posts.
    xchangePosts : Rel<Types.Xchange.Id, Types.Post.Id>;

    // to do: Threads, Discourses

  };

  public func empty (init : { admin : Principal }) : State {
    let st : State = {
      users = TrieMap.TrieMap<
      Types.User.Id,   // User Id type -- Via Motoko type system,
                       // cannot be mistaken for another entity key type, other than User.
      Types.User.User> // User data type, excluding relations we represent separately.
      (Types.User.idEqual, // Id equality check.
       Types.User.idHash); // Id hashing def. Only for internal, non-public use.

      hosts = TrieMap.TrieMap<Types.Host.Id, Types.Host.Host>
      (Types.Host.idEqual, Types.Host.idHash);

      posts = TrieMap.TrieMap<Types.Post.Id, Types.Post.Post>
      (Types.Post.idEqual, Types.Post.idHash);

      xchanges = TrieMap.TrieMap<Types.Xchange.Id, Types.Xchange.Xchange>
      (Types.Xchange.idEqual, Types.Xchange.idHash);

      userFollows = RelObj.RelObj(
        (Types.User.idHash, Types.User.idHash),
        (Types.User.idEqual, Types.User.idEqual)
      );

      userPosts = RelObj.RelObj(
        (Types.User.idHash, Types.Post.idHash),
        (Types.User.idEqual, Types.Post.idEqual)
      );

      xchangePosts = RelObj.RelObj(
        (Types.Xchange.idHash, Types.Post.idHash),
        (Types.Xchange.idEqual, Types.Post.idEqual)
      );
    };
    st
  };

}
