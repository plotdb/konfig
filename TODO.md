 - we may want to prevent race condition in multiple `build` calls.
 - font image sprite url issue
 - now update before initialized, which seems awkward. 
   - since we have passed value after init, perhaps the init update is totally unnecessary?

 - stringify / parse
   - widget may return object.
   - we may need methods in the returned object.
   - however, object may be stored as plain JSON.
   - we don't have these methods when object are loaded from plain JSON.
   - we will have to reinit them manually.
   - this creates a dependency from widget users to the widget.
   - thus, alternatively we should standardize the returned value, which shall be plain JSON.
   - users are responsible for use these values to init any object, depending on any libs.
