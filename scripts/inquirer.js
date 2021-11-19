//import inquirer from "inquirer";
const inquirer = require('inquirer');

module.exports = {
    askQuestions: () => {
        const questions = [
            {
                type: "password",
                name: "password",
                message: "Enter the admin password for the landing zone VMs",
                mask: "*",
                validate: function (value) {
                    if (value.length > 12) {
                        return true;
                    } else {
                        return 'Please enter valid password, atleast 12 charectrers.';
                    }
                }
            },
        ];
        return inquirer.prompt(questions);
    },
    askConfirm: () => {
        const questions = [
            {
                type: "confirm",
                name: "confirm",
                message: "Are you sure you want to proceed?",
            },
        ];
        return inquirer.prompt(questions);
    }
};