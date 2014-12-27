#Use Case 17: _Async Networking Collections_

- Demonstrates 2 `UICollectionView`s and 2 `UICollectionViews`s.
- Can drop from the top-most collection view to the bottom collection view.
- On drop, an asynchronous network operation is triggered and the state of the bottom collection is updated at various different intervals throughout the operation.
- Uses `AFNetworking` for network calls 
- Demonstrates how one might use the framework to perform asynchronous operations on drag / drop gestures.