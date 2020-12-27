# Shopify Intern Dev Challenge 2021

This is my spin on an image repository with Ruby on Rails and PostgreSQL. I've chosen to do this without ActiveStorage to have complete freedom with how images are handled. This choice allowed me to use background jobs (Sidekiq and Redis) for all the heavy lifting.

- **Image labelling via the Amazon Rekognition service**: On every image upload, I enque a background job on the backend that communicates with the service to fetch labels for the image.
- **Search for images with text**: Query images with the labels we got from processing.
- **Public/Private access**: Images can be made public or private. Only public images will show up in the 'Discover' page and the applicatiob blocks unauthorized/unauthenticated activity (like viewing a private image of another user, or deleting unowned images).
- **Bulk image upload**: The client retrieves presigned urls from the server and performs asynchronos direct uploads to an S3 bucket. For each successful upload, the S3 API responds with the permanent image url which the client finally posts to the server to instantiate the resource. This approach is faster than the usual ActiveStorage way because it only uploads the images to one location. Using presigned urls keeps sensitive AWS credentials away from JavaScript.
- **Fast image fetch**: An Amazon CloudFront distribution sits behind the S3 bucket. All images are fetched from this CDN which leads to fast loads.
- **Fast delete**: Like most of the other features, the actual deletion of the S3 image happens in a background job. The server only deletes the resource after a DELETE request from the client.

Besides these core featurs, this application supports pagination and secure session-based authentication.
</br>
</br>

### I'm a fan of doing things in background jobs, especially when Redis is the queue.
We just have to be careful about the assumptions we make about our resources and handle failed jobs.
</br>
</br>


## USAGE NOTES:

* The email required to create the account needn't be valid (username would've been a better choice).
* You can control your uploaded images from the 'My Uploads' page.
* If you get alerts asking for a page refresh, refreshing the page will likely solve the issue (generating a new authenticity token). So refresh the page!
* The file type validations I added are not stringent at all and can be bypassed. Nothing crazy should happen but the workers will eventually give up on trying to process the file.
