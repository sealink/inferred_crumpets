# InferredCrumpets

## 0.4.2 Unreleased

* [TT-6224] ActiveRecord::Base subjects can now take a custom crumb name

## 0.4.1

* [TT-5835] Fix crumb title for active record relation

## 0.4.0

* [TT-5807] Use crumb title for the subject name

## 0.3.0

* [TT-5087] Add parent to be displayed on index routes
* [TT-5088] Add ability to link to all actions

## 0.2.6

* [TT-4479] Added grandparent support

## 0.2.5

* [RU-145] Check for the Rails 5 ActionController::UrlGenerationError

## 0.2.4

* [TT-3102] Move url checking out into seperate class
* [TT-3102] Fix regression where subject routes where not build properly

## 0.2.3

* [TT-3117] Fix: NoMethodError when subject is not linkable

## 0.2.2

* [TT-3102] Fix: Show subject crumb even when action is not linkable

## 0.2.1

* [TT-2850] Fix: Don't link to actions that have no url

## 0.2.0

* Fix: shallow routes no longer cause a routing error
* Change: collection crumb not shown if a parent is set and the collection is shallow routed

## 0.1.2

* Fix: non-index collection actions now work

## 0.1.1

* Update: works with Crumpet 0.3.0

## 0.1.0

* Initial release
