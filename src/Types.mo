import Time "mo:base/Time";
import Hash "mo:base/Hash";
import Text "mo:base/Text";

module {

  public type Hash = Hash.Hash;
  public type Time = Time.Time;
  public type Bare = Id.Bare;
  public type Id = Id.Id;

  /// Globally-unique identifers.
  /// For instance, a human-readable hash of something.
  /// See this forum discussion: https://forum.dfinity.org/t/losing-precision-when-hashing-a-sha256-nat/6237/3
  public module Id {
    /// An untyped, `Bare` identifier.
    /// Fine to use when context is clear.
    /// When unclear, its possible to goof up the
    /// referent type of these, so `Id` clarifies that type in those cases.
    public type Bare = Text;

    /// A universally-unique identifer, by tagging the Bare id with its entity kind.
    /// Creates more descriptive API types, and prevents a class of avoidable bugs.
    public type Id = {
      #user : Bare;
      #host : Bare;
      #post : Bare;
      #thread : Bare;
      #xchange : Bare;
    };

    public func equal (i : Id, j : Id) : Bool { i == j };

    func toText (i : Id) : Text {
      switch i {
        case (#user t) { "user:" # t };
        case (#host t) { "host:" # t };
        case (#post t) { "post:" # t };
        case (#thread t) { "thread:" # t };
        case (#xchange t) { "xchange:" # t };
      }
    };

    public func hash (i : Id) : Hash {
      // more efficiency is possible by avoiding intermediate Text form.
      Text.hash (toText i)
    };
  };

  public module User {
    public type Id = { user : Bare };
    public func idEqual (i : Id, j : Id) : Bool { i == j };
    public func idHash (i : Id) : Hash { Id.hash(#user(i.user)) };
    /// Summarizes basic profile info.
    public type Summary = {
      user : Bare;  // or User.Id, to be more specific. But then user.user is annoying, so this.
      createTime : Time;
      username : Text;
    };
    /// Data for user to be stored in DB, each keyed by an Id.
    public type User = {
      createTime : Time;
      username : Text;
    };
    /// Full -- A user's "full data' is defined by their posts, in aggregate?
    ///
    /// At scale, we'd provide a way to give paginated views of
    /// these when they become too large to represent in a single
    /// message.  For a POC, we assume small datasets and this type
    /// suffices.
    public type Full = {
      summary : Summary;
      posts : [Post.Post];
    };
  };

  /// Assumnig a flow where some users, but not all, become Hosts at
  /// the end of some onboarding process, and their host record gets
  /// minted after that completes, referring to their User identifer
  /// at the time.
  public module Host {
    public type Id = { host : Bare };
    public func idEqual (i : Id, j : Id) : Bool { i == j };
    public func idHash (i : Id) : Hash { Id.hash(#host(i.host)) };
    public type Host = {
      user : Bare ; // or User.Id ...
      createTime : Time;
      // other info here?
    };
  };

  public module Post {
    public type Id = { post : Bare };
    public func idEqual (i : Id, j : Id) : Bool { i == j };
    public func idHash (i : Id) : Hash { Id.hash(#post(i.post)) };

    public type Post = {
      post : Bare;
      createTime : Time;
      /// The "kind" field of the Post record creates a chain of replies back to the "Host post"
      kind : Kind;
      body : Text;
    };
    public type Kind = {
      #fromHost : Bare; // or Host.Id ...
      #repliesTo : Bare; // or Post.Id ...
    };
  };

  public module Xchange {
    public type Id = { xchange : Bare };
    public func idEqual (i : Id, j : Id) : Bool { i == j };
    public func idHash (i : Id) : Hash { Id.hash(#xchange(i.xchange)) };
    // See comments for User.Summary
    public type Summary = {
      xchange : Bare; // or Xchange.Id ...
      createTime : Time;
      // creator? (host?)
    };
    public type Xchange = {
      createTime : Time;
      // creator? (host?)
    };
    // See comments for User.Full
    public type Full = {
      summary : Summary;
      posts : [Post.Post];
    };
  };

  public module Thread {
    public type Id = { thread : Bare };
    // See comments for User.Summary
    public type Summary = {
      thread : Bare; // or Thread.Id ...
      createTime : Time;
      // creator? (host?)
    };
    // See comments for User.Full
    public type Full = {
      summary : Summary;
      xchanges : [Xchange.Full];
    };
    // to do
  };

  public module Discourse {
    public type Id = { discourse : Bare };
    // to do
  };

}
