$(function () {
    //shorthand document.ready function

    var JSZip = require("jszip");

    function handleFile(file, zip) {
        if (!["image/png", "image/jpg", "image/jpeg"].includes(file.type)) {
            return false;
        }
        zip.file(file.name, file);
        return true;
    }

    $("form[name*='archive']").on("submit", function (e) {
        e.preventDefault();
        var zip = new JSZip();
        var files = e.currentTarget[1].files;
        for (var i = 0; i < files.length; i++) {
            if (!handleFile(files[i], zip)) {
                alert(
                    "Some of the files you uploaded are not images. Only PNG, JPEG, and JPG are supported"
                );
            }
        }
        zip.generateAsync({ type: "blob" }).then(function (blob) {
            console.log("Finished zipping. Sending to server.");
            let formElement = document.forms.namedItem("archive");
            var formData = new FormData(formElement);
            formData.append("archive[zip_file]", blob);
            formData.delete("images[]");
            fetch("/archives", {
                method: "POST",
                body: formData,
            });
        });
    });
});
