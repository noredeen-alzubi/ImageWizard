import "./semantic.min.js";

$(function () {
    let fileCount = 0;
    // $(`#1`).progress({
    //     text: {
    //         active: "Uploading...",
    //         success: "Done!",
    //         error: "Failed :(",
    //     },
    // });
    // $(`#${1}`).progress("set percent", 50);

    $("form#bulk-upload").on("submit", function (e) {
        e.preventDefault();
        let formElement = document.forms.namedItem("bulk");
        let formData = new FormData(formElement);
        var files = getFiles(e.currentTarget[1].files);
        fileCount = files.length;
        formData.append("count", files.length);
        formData.delete("image[picture][]");
        fetch("/presigned_urls", {
            method: "POST",
            body: formData,
        }).then(function (res) {
            if (res.ok) {
                // start async upload to S3
                res.json().then(function (entries) {
                    for (let i = 0; i < files.length; i++) {
                        uploadFileToS3(entries[i], files[i], i + 1);
                    }
                });
            }
        });
    });

    function getFiles(files) {
        let out = [];
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            if (["image/png", "image/jpeg"].includes(file.type)) {
                out.push(file);
            }
        }
        return out;
    }

    async function uploadFileToS3(res, file, i) {
        let target = res.url;
        let options = {
            ...res.url_fields,
        };
        let formData = new FormData();

        for (let [key, value] of Object.entries(options)) {
            formData.append(key, value);
        }

        formData.append("file", file);
        formData.append("Content-Type", file.type);

        console.log(formData);

        $("#bulk-progress").append(
            `<div class='ui segment'><div class='ui progress' data-value='0' data-total='100' id='${i}'><div class='bar'><div class='progress'></div></div><div class='label'>Uploading...</div></div>`
        );

        $(`#${i}`).progress({
            text: {
                active: "Uploading...",
                success: "Done!",
                error: "Failed :(",
            },
        });

        let xhr = new XMLHttpRequest();
        xhr.upload.addEventListener(
            "progress",
            uploadProgress.bind({ i: i }),
            false
        );
        xhr.addEventListener("load", uploadComplete.bind({ i: i }), false);
        xhr.addEventListener("error", uploadFailed.bind({ i: i }), false);
        xhr.addEventListener("abort", uploadCanceled.bind({ i: i }), false);
        xhr.open("POST", target, true);
        xhr.send(formData);
    }

    function uploadProgress(evt) {
        console.log(this.i);
        if (evt.lengthComputable) {
            let percentComplete = Math.round((evt.loaded * 100) / evt.total);
            if (percentComplete === 100) {
                percentComplete = 99;
            }
            $(`#${this.i}`).progress("set percent", percentComplete);
        }
    }

    function uploadComplete(evt) {
        if (evt.currentTarget.status === 201) {
            // success
            let xml = evt.currentTarget.responseXML;
            let location = xml.getElementsByTagName("Location")[0].childNodes[0]
                .nodeValue;
            let formElement = document.forms.namedItem("bulk");
            let formData = new FormData(formElement);
            formData.append("image[picture_url]", location);
            formData.delete("image[picture][]");
            postToServer(formData, this.i);
        }
        return null;
    }

    function uploadFailed(evt) {
        $(`#${this.i}`).progress("set error");
        console.log("FAILED");
        console.log(evt);
        console.log("\n");
    }

    function uploadCanceled(evt) {
        $(`#${this.i}`).progress("set error");
        console.log("CANCELED");
        console.log(evt);
        console.log("\n");
    }

    async function postToServer(formData, i) {
        await fetch("/bulk/single", {
            method: "POST",
            body: formData,
        }).then(function (res) {
            if (res.status === 201) {
                $(`#${i}`).progress("set success");
            } else {
                $(`#${i}`).progress("set error");
            }
        });
    }
});
