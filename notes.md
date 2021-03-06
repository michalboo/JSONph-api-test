##### 1. If this were a real story from a real life Product Owner - what questions would you ask?
> Get a 404 status code when retrieving the details of an invalid user
> Get a 200 status code when retrieving the details of a valid user

 * How can we define "valid" in this context? Is "user with the given id exists" a good enough definition?

> See the following fields in the header of a response when getting a list of users

 * After inspecting response headers for the given request, it turns out that the specified headers include the expected values, but in some cases contain other information (e.g. `Content-Type: application/json; charset=utf-8`). Is that acceptable?

> Create a new user

 * Are any specific fields required for user creation?
 * Are there any expectations surrounding field validation that should be reflected in the tests? (Can they be empty? Is there a minimum/maximum length? Are there custom validity checks on email/phone/website fields?)
 * Is inspecting the POST/DELETE response sufficient for testing user creation/deletion tests? (The API under test doesn't support this verification, but normally I would like perform a GET request confirming that e.g. a user was deleted)


##### 2. Why did you choose to structure your code in the way you did?
 * I wanted the ./lib code driving the tests to allow flexibility when invoking API requests, but still be relatively light-weight.
 * I went with a fluent interface to improve readability of the test code and allow for API requests to be constructed in a ruby-like manner (the structure of the main class was inspired by https://sendgrid.com/blog/using-ruby-to-implement-a-fluent-interface-to-any-restful-api/).
 * The tests are divided, with a separate _spec file containing some simple unit/integration tests for the ./lib code itself, and others (grouped in the /api) folder focusing on testing the API itself.

##### 3. If you had more time what improvements would you make to your code?
  * Split up /api tests a bit more.
  * Improve error/failure logging: include more relevant information regarding the failing API request (exact endpoint being called, query params etc.)
  * Experiment with running JSON Server locally - allowing for verifying data modifications.
  * Simplify the befaviour of the Client class: at the moment, because of the persisting 'path' attribute, calling a method on an existing instance can sometimes lead to unexpected results.

##### 4. What is your usual approach to testing on a project? (Hint: talk about different levels of testing you would do; who would collaborate with whom etc)
I like to advocate BDD (Behaviour Driven Development). When it comes to testing on a project, it begins with collaborating on requirements, working towards a shared understanding of "what we're building", and "how do we know we've finished building it". This normally includes some conversations around "definition of 'done'" (regardless of whether a specific definition is put in place). I like to make sure that unit and integration test coverage, as well as non-functional testing strategy are a part of these early conversations.
All of the above can serve to provide context for acceptance tests. I like to think that the entire team "owns" those, and try to collaborate on them with a product owner (helping answer questions like: "which use-cases are particularly crucial to the business?") and someone with a deep understanding of the technical/implementation side of the project (helping with e.g.: "which edge cases can be covered by unit/integration tests, and which need to be covered by end-to-end tests?")
