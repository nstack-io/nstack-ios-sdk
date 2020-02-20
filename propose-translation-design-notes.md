# Design Notes on the Propose Translation Feature

## What?
Excellent question!

The idea is that you - as a customer/project manager/developer of an app using NStack - can propose changes to texts served from NStack.

Here is how that is intended working:

1. in anything but production builds you can shake your phone
2. this will highlight all texts on the current view that are provided by NStack. For now the highlight is a yellow background.
3. you can now tap any of the highlighted texts
4. this will trigger a popover where you can:
  - view all existing translation proposals
  - suggest a new proposal
5. if you decide to suggest a new proposal, a textfield will appear where you can type your proposal
6. the proposal is sent to the backend (see the section `API Calls` later) for saving
7. furthermore the proposal is stored locally in the app for the current session
8. only one proposal per text can be made - if the proposal is the same as the already proposed value, the api will return an error. If it's different, it will override the value to the new proposal.
9. leave editmode by shaking the phone again
10. when leaving editmode (by shaking the phone), a popup will appear from the bottom, telling you if there's any proposals for the app. This popup disappears automaitcally after 3 seconds.
11. In the lists proposals, it's possible to delete a proposal from the list. If the proposal can be deleted, it's textcolor is blue. To delete a proposal, you simply swipe from right to left, to get the delete option shown.

## Components
For this to work we need the following

- Some API calls where we can:
  - store a proposal
  - fetch all stored proposals
  - delete a proposal
- Changes in the existing NStack SDK
  - A gesture recognizer listening for shakes
  - A store for proposals
    - This store must be able to serve proposed values for an NStack key if a such exists, otherwise the "normal" value from the existing `TranslationManager` will be served
    - When suggesting a proposal, this must be stored for later usage
  - UI
    - to show a popover when tapping a editable text
    - to enter a proposal
    - to see a list of all proposals for the currently selected text
    - to see a list of all proposals for the translatable subviews
  - Extensions to "NStack enabled" UI components allowing them to fetch and expose localized values
  - (optionally) some sort of syntactic sugar making it easier to use the new propose feature.

By now you might be thinking:

> can't we just use `myLabel.text = tr.this.usedToWork`

And that is understandable, it works. But unfortunately, it is no longer enough, we need to have a reference to the component from NStack so we know which value to serve it, plus what key we need to store when proposing a new value.

## Component Runthrough

### API Calls
The NStack 2.0 API enables these two API calls:

- a `POST` call to "/content/localize/proposals", allowing us to store a proposal
- a `GET` call to "/content/localize/proposals", returning an array of proposals. Add the `guid` as a queryparameter to get the info about, if the propsal can be deleted or not.
- a `DELETE` call to "/content/localize/proposals/id", where id is the id of the proposal you want to delete. Add the queryparameter `guid` to delete it from the right collection.

See more details, parameters etc. in Postman

### Gesture Recognizer
In the file `UIWindow+ShakeDetection` you will find an extension to `UIWindow`.

In the file we loop through the top viewcontroller's subviews, and adds them to an array if they conform to the `NStackLocalizable` protocol described further down. It adds resture recognizers, sets background color to indicate that the view is editable, and then stores all the relevant values needed to edit the text and for resetting the element after leaving editmode.

Note that have to "operate on UIWindow level" as this is triggered from the NStack SDK and is intended to be independent from the current UI provided by the app.


### Proposal Store
#### Overall Design
This is the `protocol` exposing the features provided by the proposal store:

```
public protocol LocalizationWrappable {}
  var bestFitLanguage: Language? { get }
  func translations<L: LocalizableModel>() throws -> L?
  func handleLocalizationModels(localizations: [LocalizationModel], acceptHeaderUsed: String?, completion: ((Error?) -> Void)?)
  func updateTranslations(_ completion: ((Error?) -> Void)?)
  func updateTranslations()

  func localize(component: NStackLocalizable, for identifier: TranslationIdentifier)
  func containsComponent(for identifier: TranslationIdentifier) -> Bool
  func storeProposal(_ value: String, locale: Locale, for identifier: TranslationIdentifier)
}
```

It might be relevant to look at the `NStackLocalizable` `protocol` as well at this moment:

```
public protocol NStackLocalizable where Self: UIView {
    func localize(for stringIdentifier: String)
    func setLocalizedValue(_ localizedValue: String)
    var translatableValue: String? { get set }
    var backgroundViewToColor: UIView? { get }
    var originalBackgroundColor: UIColor? { get set }
    var originalIsUserInteractionEnabled: Bool { get set }
    var translationIdentifier: TranslationIdentifier? { get set }
}
```

#### To Localize a UI Component
The idea is that all UI relevant components conform to `NStackLocalizable` and when they want to obtain a localized value, they call `localize` with the key they would like to obtain a localized value for.

So for instance:

`myLabel.localize(for: tr.defaultSection.yes)`

The component will pass "defaultSection.yes" the the `localize` method of `LocalizationWrappable` asking for a value, and sending themselves as a reference.

The `LocalizationWrappable` can now determine whether to use a proposed value or delegate to the existing `TranslationManager`.

Once a value has been found, the `LocalizationWrappable` calls `setLocalizedValue` on the `NStackLocalizable` component and the value is updated.

#### To Store a Proposed Value
To store a proposed value `LocalizationWrappable` must implement the `func storeProposal(_ value: String, locale: Locale, for identifier: TranslationIdentifier)`.

`TranslationIdentifier` is a wrapper class for a `section` and a `key`.

#### Memory
As we are storing references to `NStackLocalizable` items in `LocalizationWrappable` we need to ensure that these references are weak, in order to awoid memory leaks.

For this, we rely on a `NSMapTable` [documented here](https://developer.apple.com/documentation/foundation/nsmaptable) and [described here](https://nshipster.com/nshashtable-and-nsmaptable/).

#### Implementation
All of the above is implemented by the `LocalizationWrapper` class.

### UI
When shaking the phone and tapping an item, a subview will be added to the `UIWindow`. This view (including others) is stored in an array, `ShakeDetection.flowSubviews`, which is cleared after every dismissal. We use this array do know what view's to remove from thir superview when dismissing the flow.

When opening a list of proposals, we present the `ProposalViewController` modally `.overFullScreen`. This ensures that we always get the modal shown without the possibility to nagigate away from the current view. Also we get around not calling the underneath view's `viewDidAppear` or `viewWillAppear` like this.
The view is made with a presenter and an interactor as we know it from the VIPER arch, but without a coordinator, as we at the moment aren't routing anywhere.

If a propsal can be deleted, it will display with blue text instead of black. By swiping from right to left, the delete option will appear, and by tapping it, the `DELETE` call will be triggered. The `ProposalInteractor` takes care of the deletion.

### Extensions to UI Components
As already mentioned, all UI components who wishes to support NStack proposals must implement the `NStackLocalizable` protocol.

You can find implementations for:

- `UILabel` (in: UILabel+NstackLocalizable)
- `UIButton` (in: UIButton+NStackLocalizable)
- `UITextField` (in: UITextField+NStackLocalizable)
- `UITextView` (in: UITextView+NStackLocalizable)
