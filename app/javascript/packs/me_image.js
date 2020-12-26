$(function () {
    $("#checkbox").on("change", function (e) {
        console.log(e);
        $("#loader").removeClass("hidden");
        submitForm(e.target.checked).then(function (res) {
            $("#loader").addClass("hidden");
            if (res.status == 200) {
                $("#loader").addClass("hidden");
                $("#status").text(
                    e.target.checked
                        ? "Private (won't show up in Discover and cannot be directly accessed)"
                        : "Private"
                );
            } else {
                alert("Sorry, that didn't work. Maybe refresh?");
            }
        });
    });

    $("form#privacy").on("submit", function (e) {
        e.preventDefault();
    });

    async function submitForm(checked) {
        let formElement = document.forms.namedItem("privacy");
        let formData = new FormData(formElement);
        formData.append("image[private]", checked);
        return await fetch(formElement.action, {
            method: "PATCH",
            body: formData,
        });
    }
});
